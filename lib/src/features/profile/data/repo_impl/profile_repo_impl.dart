import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../services/service_locator.dart';
import '../../domain/repo/profile_repo.dart';
import '../model/doctor_model.dart';

class ProfileRepoImpl implements ProfileRepo {
  final FirebaseFirestore _firestore = serviceLocator<FirebaseFirestore>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<List<DoctorModel>> getDoctors(String patientId, {DocumentSnapshot? lastDocument}) async {
    try {
      Query query = _firestore
          .collection('doctors')
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .limit(10);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch doctors: ${e.toString()}');
    }
  }

  @override
  Future<void> addDoctor(DoctorModel doctor) async {
    try {
      await _firestore.collection('doctors').add(doctor.toFirestore());
    } catch (e) {
      throw Exception('Failed to add doctor: ${e.toString()}');
    }
  }

  @override
  Future<void> updateDoctor(DoctorModel doctor) async {
    try {
      if (doctor.id == null) {
        throw Exception('Doctor ID is required for update');
      }
      await _firestore.collection('doctors').doc(doctor.id).update(doctor.toFirestore());
    } catch (e) {
      throw Exception('Failed to update doctor: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDoctor(String doctorId) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).delete();
    } catch (e) {
      throw Exception('Failed to delete doctor: ${e.toString()}');
    }
  }
}
