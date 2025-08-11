import 'dart:convert';
import 'dart:io';

import 'package:base_architecture/src/shared/utilities/debug_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import '../../../../services/service_locator.dart';
import '../../../../shared/constants/api_constants.dart';
import '../../domain/repo/summary_repo.dart';
import '../model/summary_model.dart';

class SummaryRepoImpl implements SummaryRepo {
  final FirebaseFirestore _firestore = serviceLocator<FirebaseFirestore>();
  final Dio _dio = Dio();

  @override
  Future<List<SummaryModel>> getSummaries(
    String patientId, {
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('summary')
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .limit(10);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => SummaryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch summaries: ${e.toString()}');
    }
  }

  @override
  Future<String?> getDoctorName(String doctorId) async {
    try {
      if (doctorId.isEmpty) return null;

      final doc = await _firestore.collection('doctors').doc(doctorId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['name'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<SummaryModel?> getSummaryById(String id) async {
    try {
      final doc = await _firestore.collection('summary').doc(id).get();
      if (!doc.exists) return null;
      return SummaryModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch summary: ${e.toString()}');
    }
  }

  @override
  Future<SummaryCreationResult> createSummaryFromRecording({
    required String patientId,
    required String doctorId,
    required String filePath,
  }) async {
    final String url =
        '${ApiConst.deepgramBaseUrl}?summarize=v2&diarize=true&language=en&model=nova-3';

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Recording file missing');
    }

    final response = await _dio.post(
      url,
      data: file.openRead(),
      options: Options(
        headers: {
          'Authorization': 'Token ${ApiConst.deepgramApiKey}',
          'Content-Type': 'audio/*',
        },
        responseType: ResponseType.json,
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as Map<String, dynamic>;
    String? summaryText;
    if (results.containsKey('summary')) {
      final summary = results['summary'] as Map<String, dynamic>;
      summaryText = summary['short'] as String?;
    }
    summaryText ??= _extractTranscript(data);

    final followUpQuestions = await getFollowUpQuestions(
      summary: summaryText ?? "",
    );
    printMessage("doctorId: $doctorId");
    if (summaryText == null || summaryText.isEmpty) {
      throw Exception('Please try again, no summary generated');
    }

    final doc = await _firestore.collection('summary').add({
      'patientId': patientId,
      'doctorId': doctorId,
      'title': 'Visit Summary',
      'summaryText': summaryText,
      'recordingPath': filePath,
      'followUpQuestions': followUpQuestions,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return SummaryCreationResult(
      documentId: doc.id,
      summaryText: summaryText ?? "",
      followUpQuestions: followUpQuestions,
    );
  }

  @override
  Future<List<String>> getFollowUpQuestions({required String summary}) async {
    try {
      final String url = ApiConst.groqBaseUrl;

      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConst.groqApiKey}',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
        ),
        data: {
          "model": "openai/gpt-oss-20b",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a medical follow-up assistant.\nYou will receive a summary of a conversation between a doctor and a patient.\nFrom this summary, generate exactly three short, clear, and highly relevant follow-up questions that the patient should ask the doctor in their next appointment.\n\nGuidelines:\n- Output only a plain JSON array (list) of strings — no keys, no extra text.\n- The questions must be directly related to the patient's medical condition, diagnosis, treatment plan, or test results mentioned in the summary.\n- Avoid generic or unrelated questions.\n- Keep each question short (maximum 15 words) and easy for the patient to understand.\n- Do not add explanations or extra context.\n\nExample Input:\nSummary: The patient reported recurring headaches and blurred vision. The doctor suggested an MRI scan and prescribed medication to reduce inflammation. The doctor also mentioned the possibility of high eye pressure but advised confirming with further tests.\n\nExample Output:\n[\n  \"What could be causing my recurring headaches and blurred vision?\",\n  \"How soon should I get the MRI scan done?\",\n  \"What does high eye pressure mean for my long-term health?\"\n]",
            },
            {"role": "user", "content": "Summary: $summary"},
          ],
          "temperature": 0.5,
          "max_completion_tokens": 512,
          "top_p": 1,
          "reasoning_effort": "medium",
          "stream": false,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final content = data["choices"]?[0]?["message"]?["content"];

      if (content is String) {
        try {
          final parsed = List<String>.from(json.decode(content));
          return parsed;
        } catch (_) {
          return content
              .split("\n")
              .map((q) => q.trim())
              .where((q) => q.isNotEmpty)
              .toList();
        }
      }

      throw Exception("Invalid response format: $data");
    } catch (e) {
      throw Exception('Failed to fetch follow-up questions: ${e.toString()}');
    }
  }

  String? _extractTranscript(Map<String, dynamic> data) {
    try {
      final channels = data['results']['channels'] as List<dynamic>;
      final first = channels.first as Map<String, dynamic>;
      final alts = first['alternatives'] as List<dynamic>;
      final alt0 = alts.first as Map<String, dynamic>;
      final transcript = (alt0['transcript'] as String?)?.trim();
      return transcript;
    } catch (_) {
      return null;
    }
  }
}
