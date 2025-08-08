import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../services/service_locator.dart';
import '../../domain/repo/summary_repo.dart';
import '../model/summary_model.dart';

class SummaryRepoImpl implements SummaryRepo {
  final FirebaseFirestore _firestore = serviceLocator<FirebaseFirestore>();

  @override
  Future<List<SummaryModel>> getSummaries(String patientId, {DocumentSnapshot? lastDocument}) async {
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
      return snapshot.docs.map((doc) => SummaryModel.fromFirestore(doc)).toList();
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
      // Return null if doctor not found or error
      return null;
    }
  }
}
