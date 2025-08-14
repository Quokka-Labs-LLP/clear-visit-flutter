import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/model/summary_model.dart';

abstract class SummaryRepo {
  Future<List<SummaryModel>> getSummaries(
    String patientId, {
    DocumentSnapshot? lastDocument,
  });
  Future<String?> getDoctorName(String doctorId);
  Future<SummaryCreationResult> createSummaryFromRecording({
    required String patientId,
    required String doctorId,
    required String filePath,
  });

  Future<List<String>> getFollowUpSummaryAndQuestions({
    required String transcript,
  });

  Future<SummaryModel?> getSummaryById(String id);
}

class SummaryCreationResult {
  final String documentId;
  final String summaryText;
  final List<String> followUpQuestions;
  SummaryCreationResult({
    required this.documentId,
    required this.summaryText,
    required this.followUpQuestions,
  });
}
