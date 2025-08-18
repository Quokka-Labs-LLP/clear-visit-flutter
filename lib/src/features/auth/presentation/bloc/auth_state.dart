part of 'auth_bloc.dart';

class AuthState {
  final StateStatus apiCallStatus;
  final SampleModel? sampleModel;
  final String mobileNumber;
  final bool isMobileValid;
  final String? mobileError;
  final bool isSignInMode;
  final StateStatus signInStatus;
  final StateStatus appleSignInStatus;
  final StateStatus googleSignInStatus;
  final String? name;
   StateStatus setNameStatus;
  final StateStatus logoutStatus;
  final bool isNewSignup;

  AuthState({
    this.apiCallStatus = const StateNotLoaded(),
    this.sampleModel,
    this.mobileNumber = '',
    this.isMobileValid = false,
    this.mobileError,
    this.isSignInMode = true,
    this.name,
    this.signInStatus = const StateNotLoaded(),
    this.appleSignInStatus = const StateNotLoaded(),
    this.googleSignInStatus = const StateNotLoaded(),
    this.setNameStatus = const StateNotLoaded(),
    this.logoutStatus = const StateNotLoaded(),
    this.isNewSignup = false,
  });

  AuthState copyWith({
    final StateStatus? apiCallStatus,
    final SampleModel? sampleModel,
    final String? mobileNumber,
    final bool? isMobileValid,
    final String? mobileError,
    final bool? isSignInMode,
    final StateStatus? signInStatus,
    final StateStatus? appleSignInStatus,
    final StateStatus? googleSignInStatus,
    final String? name,
    final StateStatus? setNameStatus,
    final StateStatus? logoutStatus,
    final bool? isNewSignup,
  }) => AuthState(
    apiCallStatus: apiCallStatus ?? this.apiCallStatus,
    sampleModel: sampleModel ?? this.sampleModel,
    mobileNumber: mobileNumber ?? this.mobileNumber,
    isMobileValid: isMobileValid ?? this.isMobileValid,
    mobileError: mobileError,
    isSignInMode: isSignInMode ?? this.isSignInMode,
    signInStatus: signInStatus ?? this.signInStatus,
    appleSignInStatus: appleSignInStatus ?? this.appleSignInStatus,
    googleSignInStatus: googleSignInStatus ?? this.googleSignInStatus,
    name: name ?? this.name,
    setNameStatus: setNameStatus ?? this.setNameStatus,
    logoutStatus: logoutStatus ?? this.logoutStatus,
    isNewSignup: isNewSignup ?? this.isNewSignup,
  );
}