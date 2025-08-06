import 'dart:async';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../services/service_locator.dart';
import '../../domain/repo/auth_repo.dart';

class AuthRepoImpl extends AuthRepo {
  final Dio _dio = serviceLocator<Dio>();


  @override
  Future<void> signInWithApple() async {
    try {
    } catch (e) {
      debugPrint('Apple Sign In failed: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<Either<String, String>> signInWithGoogle() async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      
      await signIn.initialize(
        clientId: Platform.isIOS ? '':null,
        serverClientId: null,
      );

      // Set up authentication event listener
      final StreamSubscription<GoogleSignInAuthenticationEvent> subscription =
      signIn.authenticationEvents.listen(
              (GoogleSignInAuthenticationEvent event) async {
            final GoogleSignInAccount? user = switch (event) {
              GoogleSignInAuthenticationEventSignIn() => event.user,
              GoogleSignInAuthenticationEventSignOut() => null,
            };

            if (user != null) {
              debugPrint('Google Sign In successful: ${user.email}');
            }
        },
        onError: (Object e) {
          debugPrint('Google Sign In error: $e');
        },
      );

      // Trigger the sign-in process
      final GoogleSignInAccount? googleUser = await signIn.authenticate();
      
      // Clean up the subscription
      await subscription.cancel();

      if (googleUser == null) {
        return left('Sign in cancelled');
      }

      return right(googleUser.email);
    } catch (e) {
      debugPrint('Google Sign In failed: ${e.toString()}');
      return left('Google Sign In failed: ${e.toString()}');
    }
  }
}
