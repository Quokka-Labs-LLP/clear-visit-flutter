import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/model/doctor_model.dart';

abstract class ProfileRepo {
  Future<List<DoctorModel>> getDoctors(String patientId, {DocumentSnapshot? lastDocument});
  Future<void> addDoctor(DoctorModel doctor);
  Future<void> updateDoctor(DoctorModel doctor);
  Future<void> deleteDoctor(String doctorId);
}
