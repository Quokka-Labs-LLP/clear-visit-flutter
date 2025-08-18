import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../services/service_locator.dart';

class TrialService {
  final FirebaseFirestore _firestore = serviceLocator<FirebaseFirestore>();
  final FirebaseAuth _auth = serviceLocator<FirebaseAuth>();

  /// Check if user is eligible for practice trial
  Future<bool> isEligibleForTrial() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // New user, eligible for trial
        return true;
      }

      final data = userDoc.data();
      if (data == null) return true;

      // Check if practiceModeAccessed is true
      final practiceModeAccessed = data['practiceModeAccessed'] as bool?;
      return practiceModeAccessed != true;
    } catch (e) {
      // In case of error, allow trial (fail-safe)
      return true;
    }
  }

  /// Mark trial as completed
  Future<void> markTrialCompleted() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'practiceModeAccessed': true,
        'trialCompletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't throw
      debugPrint('Failed to mark trial as completed: $e');
    }
  }

  /// Get trial status for display purposes
  Future<Map<String, dynamic>> getTrialStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {'eligible': false, 'error': 'No user'};

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        return {'eligible': true, 'isNewUser': true};
      }

      final data = userDoc.data();
      if (data == null) return {'eligible': true, 'isNewUser': false};

      final practiceModeAccessed = data['practiceModeAccessed'] as bool?;
      final trialCompletedAt = data['trialCompletedAt'] as Timestamp?;

      return {
        'eligible': practiceModeAccessed != true,
        'isNewUser': false,
        'trialCompletedAt': trialCompletedAt,
      };
    } catch (e) {
      return {'eligible': false, 'error': e.toString()};
    }
  }
}
