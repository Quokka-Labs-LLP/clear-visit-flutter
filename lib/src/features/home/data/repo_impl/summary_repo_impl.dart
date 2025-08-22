import 'dart:convert';
import 'dart:io';

import 'package:base_architecture/src/shared/utilities/debug_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../services/service_locator.dart';
import '../../../../shared/constants/api_constants.dart';
import '../../domain/repo/summary_repo.dart';
import '../model/summary_model.dart';
import 'package:path/path.dart' as p;

class SummaryRepoImpl implements SummaryRepo {
  final FirebaseFirestore _firestore = serviceLocator<FirebaseFirestore>();
  final FirebaseStorage _storage = serviceLocator<FirebaseStorage>();

  final Dio _dio = Dio();

  Future<File> _compressAudioFile(File inputFile) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.mp3';

    final command =
        '-i "${inputFile.path}" -b:a 128k -ar 44100 -ac 2 "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (returnCode?.isValueSuccess() ?? false) {
      return File(outputPath);
    } else {
      final logs = await session.getAllLogsAsString();
      throw Exception('Audio compression failed: $logs');
    }
  }

  String _generateFileNameForUpload({
    required String filePath,
    required String doctorId,
    required String patientId,
  }) {
    final file = File(filePath);
    final bytes = file.readAsBytesSync();
    final digest = md5.convert(bytes).toString(); // crypto package
    final ext = p.extension(filePath);

    final fileName = '${doctorId}_$patientId\_$digest$ext';
    printMessage("File name generated: $fileName");
    return fileName;
  }

  Future<void> startUploadRecordingAndUpdateFirestore({
    required String docId,
    required String filePath,
    required String doctorId,
    required String patientId,
  }) async {
    final fileName = _generateFileNameForUpload(
      filePath: filePath,
      doctorId: doctorId,
      patientId: patientId,
    );

    final storagePath = 'recording/$fileName';
    final originalFile = File(filePath);

    printMessage("Storage path for upload: $storagePath");

    File fileToUpload = originalFile;
    try {
      fileToUpload = await _compressAudioFile(originalFile);
      printMessage("Compression successful: ${fileToUpload.path}");
    } catch (e) {
      printError('Compression failed, using original file: $e');
    }

    final ref = _storage.ref().child(storagePath);
    final uploadTask = ref.putFile(fileToUpload);

    final subscription = uploadTask.snapshotEvents.listen(
      (snapshot) async {
        final transferred = snapshot.bytesTransferred;
        final total = snapshot.totalBytes;
        final progress = total > 0 ? transferred / total : 0.0;

        try {
          await _firestore.collection('summary').doc(docId).update({
            'uploadProgress': progress,
            'uploadStatus': 'uploading',
          });
        } catch (_) {}
      },
      onError: (e) async {
        await _firestore.collection('summary').doc(docId).update({
          'uploadStatus': 'failed',
          'uploadError': e.toString(),
        });
      },
    );

    // Wait for completion
    try {
      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();
      await _firestore.collection('summary').doc(docId).update({
        'recordingUrl': downloadUrl,
        'uploadStatus': 'completed',
        'uploadProgress': 1.0,
      });
    } catch (e) {
      await _firestore.collection('summary').doc(docId).update({
        'uploadStatus': 'failed',
        'uploadError': e.toString(),
      });
    } finally {
      await subscription.cancel();
    }
  }

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
    String? transcript;
    transcript ??= _extractTranscript(data);

    printMessage("doctorId: $doctorId");
    final rawTranscript = (transcript ?? '').trim();
    if (rawTranscript.isEmpty) {
      throw Exception('No recording found, please try again');
    }
    // if (!_looksLikeDoctorPatientConversation(rawTranscript)) {
    //   throw Exception('No conversation recorded, please try again');
    // }
    final summaryAndQuestions = await getFollowUpSummaryAndQuestions(
      transcript: transcript ?? "",
    );

    // final docRef = await _firestore.collection('summary').add({
    //   'patientId': patientId,
    //   'doctorId': doctorId,
    //   'title': 'Visit Summary',
    //   'summaryText': summaryAndQuestions.first,
    //   'recordingPath': filePath,
    //   'recordingUrl': null,
    //   'followUpQuestions': summaryAndQuestions.sublist(1, 4),
    //   'createdAt': FieldValue.serverTimestamp(),
    //   'uploadStatus': 'pending',
    //   'uploadProgress': 0.0,
    // });

    // startUploadRecordingAndUpdateFirestore(
    //   docId: docRef.id,
    //   filePath: filePath,
    //   doctorId: doctorId,
    //   patientId: patientId,
    // );

    return SummaryCreationResult(
      documentId: "docRef.id",
      summaryText: summaryAndQuestions.first,
      followUpQuestions: summaryAndQuestions.sublist(1, 4),
    );
  }

  @override
  Future<List<String>> getFollowUpSummaryAndQuestions({
    required String transcript,
  }) async {
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
            {"role": "system", "content": ApiConst.sysytemPrompt},
            {"role": "user", "content": "Transcript: $transcript"},
          ],
          "temperature": 0.5,
          "max_completion_tokens": 768,
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

          if (parsed.length == 5) {
            return parsed;
          } else {
            throw Exception(
              "Expected 5 elements (summary + 4 questions), got ${parsed.length}",
            );
          }
        } catch (_) {
          throw Exception("Invalid JSON output: $content");
        }
      }

      throw Exception("Invalid response format: $data");
    } catch (e) {
      throw Exception(
        'Failed to fetch summary & follow-up questions: ${e.toString()}',
      );
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

  bool _looksLikeDoctorPatientConversation(String transcript) {
    final t = transcript.toLowerCase();
    if (t.length < 40) return false;
    final hasDoctor = t.contains('doctor') || t.contains('dr ');
    final hasPatient = t.contains('patient');
    final hasMedical = RegExp(r'\b(symptom|medication|dose|prescription|diagnosis|treatment|allerg|pain|blood pressure|bp|follow-up)\b').hasMatch(t);
    return (hasDoctor && hasPatient) || (hasDoctor && hasMedical) || (hasPatient && hasMedical);
  }
}
