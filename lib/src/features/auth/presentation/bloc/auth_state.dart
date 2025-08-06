part of 'auth_bloc.dart';

class AuthState {
  final StateStatus apiCallStatus;
  final SampleModel? sampleModel;
  final String mobileNumber;
  final bool isMobileValid;
  final String? mobileError;
  final bool isSignInMode;

  AuthState({
    this.apiCallStatus = const StateNotLoaded(),
    this.sampleModel,
    this.mobileNumber = '',
    this.isMobileValid = false,
    this.mobileError,
    this.isSignInMode = true,
  });

  AuthState copyWith({
    final StateStatus? apiCallStatus,
    final SampleModel? sampleModel,
    final String? mobileNumber,
    final bool? isMobileValid,
    final String? mobileError,
    final bool? isSignInMode,
  }) => AuthState(
    apiCallStatus: apiCallStatus ?? this.apiCallStatus,
    sampleModel: sampleModel ?? this.sampleModel,
    mobileNumber: mobileNumber ?? this.mobileNumber,
    isMobileValid: isMobileValid ?? this.isMobileValid,
    mobileError: mobileError,
    isSignInMode: isSignInMode ?? this.isSignInMode,
  );
}
