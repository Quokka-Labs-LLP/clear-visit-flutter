import 'dart:async';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../services/service_locator.dart';
import '../../../../shared_pref_services/shared_pref_base_service.dart';
import '../../../../shared_pref_services/shared_pref_keys.dart';
import '../../domain/repo/auth_repo.dart';

class AuthRepoImpl extends AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestore = serviceLocator<FirebaseFirestore>();

  @override
  Future<void> signInWithApple() async {
    try {
    } catch (e) {
      debugPrint('Apple Sign In failed: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<Either<String, String>> setUsername({required String username, required bool fromSignUpPage}) async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) return left('User not logged in');

      // Step 1: Update Firebase Auth displayName
      await user.updateDisplayName(username);

      // Step 2: Set or update Firestore user document
      final docRef = firestore.collection('users').doc(user.uid);

      await docRef.set(
        {'name': username},
        SetOptions(merge: true), // merge = update if exists
      );
      final pref = serviceLocator<SharedPreferenceBaseService>();
      await pref.setAttribute(SharedPrefKeys.name, username);
      if(fromSignUpPage) {
        await pref.setAttribute(SharedPrefKeys.isOnboarded, true);
      }
      return right(username);
    } catch (e) {
      debugPrint('Error setting username: ${e.toString()}');
      return left('Something went wrong: ${e.toString()}');
    }
  }


  @override
  Future<Either<String, GoogleSignInAccount>> signInWithGoogle() async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;

      await signIn.initialize(
        clientId: Platform.isIOS ? '124980859440-93hlikit5q9a25ffbjhcas3utf1rm6fq.apps.googleusercontent.com':null,
        serverClientId: Platform.isIOS ? null:"113312680290266458742",
      );
      // Set up authentication event listener
      final GoogleSignInAccount account = await signIn.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      return right(account);
    } on GoogleSignInException catch (e) {
      debugPrint('error while Google Sign-In===> ${e.toString()}');
      return left(e.toString());
    } catch (e) {
      debugPrint('Google Sign In failed: ${e.toString()}');
      return left('Google Sign In failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Clear all SharedPreferences
      final sharedPref = serviceLocator<SharedPreferenceBaseService>();
      await sharedPref.clearPreferences();

      debugPrint("✅ User logged out and SharedPreferences cleared.");
    } catch (e) {
      debugPrint("❌ Logout failed: ${e.toString()}");
      rethrow;
    }
  }


}