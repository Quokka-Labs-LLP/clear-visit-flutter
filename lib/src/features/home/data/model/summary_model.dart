import 'package:cloud_firestore/cloud_firestore.dart';

class SummaryModel {
  final String? id;
  final String patientId;
  final String doctorId;
  final String title;
  final String? preview;
  final String? summaryText;
  final String? recordingPath;
  final List<String>? followUpQuestions;
  final Timestamp createdAt;
  final String? recordingUrl;
  final String? uploadStatus;

  SummaryModel({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.title,
    this.preview,
    this.summaryText,
    this.recordingPath,
    this.followUpQuestions,
    required this.createdAt,
    this.recordingUrl,
    this.uploadStatus,
  });

  factory SummaryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SummaryModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '', // Note: using 'doctorid' as per Firebase field
      title: data['title'] ?? '',
      preview: data['preview'],
      summaryText: data['summaryText'],
      recordingPath: data['recordingPath'],
      followUpQuestions: data['followUpQuestions'] != null 
          ? List<String>.from(data['followUpQuestions'])
          : null,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      recordingUrl: data['recordingUrl'] ?? '',
      uploadStatus: data['uploadStatus'] ?? '',
    );
  }
}
