import 'package:cloud_firestore/cloud_firestore.dart';

class SummaryModel {
  final String? id;
  final String? patientId;
  final String? doctorId;
  final String? doctorName; // Placeholder for doctor name, to be resolved later
  final String? title;
  final String? preview;
  final String? summaryText;
  final String? recordingPath;
  final List<String>? followUpQuestions;
  final Timestamp? createdAt;
  final String? recordingUrl;
  final String? uploadStatus;

  SummaryModel({
    this.id,
    this.patientId,
    this.doctorId,
    this.title,
    this.preview,
    this.doctorName,
    this.summaryText,
    this.recordingPath,
    this.followUpQuestions,
    this.createdAt,
    this.recordingUrl,
    this.uploadStatus,
  });

  factory SummaryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SummaryModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId:
          data['doctorId'] ??
          '', // Note: using 'doctorid' as per Firebase field
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
  SummaryModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? doctorName,
    String? title,
    String? preview,
    String? summaryText,
    String? recordingPath,
    List<String>? followUpQuestions,
    Timestamp? createdAt,
    String? recordingUrl,
    String? uploadStatus,
  }) => SummaryModel(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    doctorId: doctorId ?? this.doctorId,
    doctorName: doctorName ?? this.doctorName,
    title: title ?? this.title,
    preview: preview ?? this.preview,
    summaryText: summaryText ?? this.summaryText,
    recordingPath: recordingPath ?? this.recordingPath,
    followUpQuestions: followUpQuestions ?? this.followUpQuestions,
    createdAt: createdAt ?? this.createdAt,
    recordingUrl: recordingUrl ?? this.recordingUrl,
    uploadStatus: uploadStatus ?? this.uploadStatus,
  );
}
