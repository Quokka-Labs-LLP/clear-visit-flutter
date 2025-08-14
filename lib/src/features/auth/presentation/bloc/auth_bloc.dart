import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/service_locator.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../../../shared_pref_services/shared_pref_base_service.dart';
import '../../../../shared_pref_services/shared_pref_keys.dart';
import '../../data/model/sample_model.dart';
import '../../domain/repo/auth_repo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo _authRepo = serviceLocator<AuthRepo>();

  AuthBloc() : super(AuthState()) {
    on<OnNameSubmitted>((final event, final emit) async {
      final name = event.name.trim();
      emit(state.copyWith(
        name: name,
        setNameStatus:  StateLoading(),
      ));
      try {
        final result = await _authRepo.setUsername(username: name, fromSignUpPage: event.fromSignUpPage);
        result.fold(
          (error) {
            emit(state.copyWith(
              setNameStatus:  StateFailed(errorMessage: error),
            ));
          },
          (success) {
            emit(state.copyWith(
              setNameStatus: StateLoaded(successMessage: 'Name updated successfully'),
            ));
          },
        );
      } catch (e) {
        emit(state.copyWith(
          setNameStatus: StateFailed(errorMessage: 'Failed to update name: ${e.toString()}'),
        ));
      }
    });

    on<OnMobileSignInEvent>((final event, final emit) async {
      if (!state.isMobileValid) return;

      emit(state.copyWith(apiCallStatus: StateLoading()));
      try {
        // TODO: Implement actual sign-in API call
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        emit(state.copyWith(
            apiCallStatus: StateLoaded(successMessage: 'Sign-in successful')));
      } catch (e) {
        emit(state.copyWith(
            apiCallStatus: StateFailed(errorMessage: 'Sign-in failed')));
      }
    });

    on<OnSignUpEvent>((final event, final emit) async {
      if (!state.isMobileValid) return;

      emit(state.copyWith(apiCallStatus: StateLoading()));
      try {
        // TODO: Implement actual sign-up API call
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        emit(state.copyWith(
            apiCallStatus: StateLoaded(successMessage: 'Sign-up successful')));
      } catch (e) {
        emit(state.copyWith(
            apiCallStatus: StateFailed(errorMessage: 'Sign-up failed')));
      }
    });

    on<OnToggleAuthMode>((final event, final emit) {
      emit(state.copyWith(isSignInMode: !state.isSignInMode));
    });

    on<OnAppleSignInEvent>((event, emit) async {
      emit(state.copyWith(appleSignInStatus: StateLoading()));
      try {
        await _authRepo.signInWithApple();
        emit(state.copyWith(appleSignInStatus: StateLoaded(
            successMessage: 'Apple Sign-In successful')));
      } catch (e) {
        emit(state.copyWith(appleSignInStatus: StateFailed(
            errorMessage: 'Apple Sign-In failed: \\${e.toString()}')));
      }
    });

    on<OnGoogleSignInEvent>((event, emit) async {
      emit(state.copyWith(googleSignInStatus: StateLoading()));

      try {
        final apiResult = await _authRepo.signInWithGoogle();

        if (apiResult.isLeft()) {
          final error = apiResult.fold((l) => l, (_) => '');
          emit(state.copyWith(
            googleSignInStatus: StateFailed(
                errorMessage: 'Google Sign-In failed: $error'),
          ));
          return;
        }

        final googleUser = apiResult.fold((_) => null, (r) => r)!;

        try {
          final googleAuth = await googleUser.authentication;

          final credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
          );

          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);
          final user = userCredential.user;

          if (user != null) {
            debugPrint("Firebase UID: ${user.uid}");

            final firestore = serviceLocator<FirebaseFirestore>();
            final usersRef = firestore.collection('users').doc(user.uid);
            final userDoc = await usersRef.get();

            final pref = serviceLocator<SharedPreferenceBaseService>();

            // Determine if names exist
            String? firstName;
            String? lastName;
            bool hasNames = false;
            final bool docExisted = userDoc.exists;
            if (docExisted) {
              final data = userDoc.data() as Map<String, dynamic>;
              firstName = (data['firstName'] as String?)?.trim();
              lastName = (data['lastName'] as String?)?.trim();
              hasNames = (firstName != null && firstName.isNotEmpty) && (lastName != null && lastName.isNotEmpty);
            }

            if (!docExisted || !hasNames) {
              // Derive names from displayName
              final displayName = (user.displayName ?? '').trim();
              final parts = displayName.split(' ');
              firstName = parts.isNotEmpty ? parts.first : '';
              lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

              await usersRef.set({
                'firstName': firstName,
                'lastName': lastName,
                'email': user.email,
                'createdAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }

            // Treat only brand-new accounts as new signup; existing accounts go straight home
            final isNewSignup = !docExisted;
            await pref.setAttribute(SharedPrefKeys.isLoggedIn, true);
            await pref.setAttribute(SharedPrefKeys.isOnboarded, !isNewSignup);

            // ✅ Always update other user info locally
            await pref.setAttribute(SharedPrefKeys.authId, user.uid);
            await pref.setAttribute(SharedPrefKeys.email, user.email);
            await pref.setAttribute(
                SharedPrefKeys.name, user.displayName ?? '');

            debugPrint("User signed in with Google: ${user.email}");

            emit(state.copyWith(
              googleSignInStatus: StateLoaded(successMessage: 'Google Sign-In successful'),
              isNewSignup: isNewSignup,
            ));
          } else {
            emit(state.copyWith(
              googleSignInStatus: StateFailed(
                  errorMessage: 'Firebase authentication failed'),
            ));
          }
        } catch (firebaseError) {
          emit(state.copyWith(
            googleSignInStatus: StateFailed(
              errorMessage: 'Firebase auth error: ${firebaseError.toString()}',
            ),
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          googleSignInStatus: StateFailed(
              errorMessage: 'Unexpected error: ${e.toString()}'),
        ));
      }
    });

    on<OnLogout>((event, emit) async {
      emit(state.copyWith(logoutStatus: StateLoading()));
      try {
        await _authRepo.signOut();
        emit(state.copyWith(logoutStatus: StateLoaded(
            successMessage: 'Apple Sign-In successful')));
      } catch (e) {
        emit(state.copyWith(logoutStatus: StateFailed(
            errorMessage: 'Apple Sign-In failed: \\${e.toString()}')));
      }
    });

    on<GetUserName>((event, emit) async {
        final sharedPref = serviceLocator<SharedPreferenceBaseService>();
        final savedName = await sharedPref.getAttribute(SharedPrefKeys.name, '');
        emit(state.copyWith(name: savedName));
    });

  }

}