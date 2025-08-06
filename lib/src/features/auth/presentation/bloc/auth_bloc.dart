import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/service_locator.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../data/model/sample_model.dart';
import '../../domain/repo/auth_repo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo _apiRepo = serviceLocator<AuthRepo>();

  AuthBloc() : super(AuthState()) {
    on<OnLoginEvent>((final event, final emit) async {
      emit(state.copyWith(apiCallStatus: StateLoading()));
      final SampleModel sampleModel = await _apiRepo.sampleApiCall();
      /// HERE will check api status code & return data
      emit(state.copyWith(apiCallStatus: StateLoaded(successMessage: sampleModel.message ?? ''), sampleModel: sampleModel));
    });

    on<OnValidateMobileEvent>((final event, final emit) {
      final mobileNumber = event.mobileNumber.trim();
      final isValid = _validateMobileNumber(mobileNumber);
      final error = isValid ? null : 'Please enter a valid mobile number';
      
      emit(state.copyWith(
        mobileNumber: mobileNumber,
        isMobileValid: isValid,
        mobileError: error,
      ));
    });

    on<OnMobileSignInEvent>((final event, final emit) async {
      if (!state.isMobileValid) return;
      
      emit(state.copyWith(apiCallStatus: StateLoading()));
      try {
        // TODO: Implement actual sign-in API call
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        emit(state.copyWith(apiCallStatus: StateLoaded(successMessage: 'Sign-in successful')));
      } catch (e) {
        emit(state.copyWith(apiCallStatus: StateFailed(errorMessage: 'Sign-in failed')));
      }
    });

    on<OnSignUpEvent>((final event, final emit) async {
      if (!state.isMobileValid) return;
      
      emit(state.copyWith(apiCallStatus: StateLoading()));
      try {
        // TODO: Implement actual sign-up API call
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        emit(state.copyWith(apiCallStatus: StateLoaded(successMessage: 'Sign-up successful')));
      } catch (e) {
        emit(state.copyWith(apiCallStatus: StateFailed(errorMessage: 'Sign-up failed')));
      }
    });

    on<OnToggleAuthMode>((final event,final emit) {
      emit(state.copyWith(isSignInMode: !state.isSignInMode));
    });
  }

  bool _validateMobileNumber(String mobileNumber) {
    // Basic mobile number validation (10 digits)
    final RegExp mobileRegex = RegExp(r'^[0-9]{10}$');
    return mobileRegex.hasMatch(mobileNumber);
  }
}
