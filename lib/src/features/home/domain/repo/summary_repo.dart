import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/model/summary_model.dart';

abstract class SummaryRepo {
  Future<List<SummaryModel>> getSummaries(String patientId, {DocumentSnapshot? lastDocument});
  Future<String?> getDoctorName(String doctorId);
}
