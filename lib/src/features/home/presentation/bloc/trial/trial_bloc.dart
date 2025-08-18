import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/trial_service.dart';
import '../../../../../shared/utilities/event_status.dart';

part 'trial_event.dart';
part 'trial_state.dart';

class TrialBloc extends Bloc<TrialEvent, TrialState> {
  final TrialService _trialService = TrialService();

  TrialBloc() : super(const TrialState()) {
    on<CheckTrialEligibility>(_onCheckTrialEligibility);
    on<MarkTrialCompleted>(_onMarkTrialCompleted);
  }

  Future<void> _onCheckTrialEligibility(
    CheckTrialEligibility event,
    Emitter<TrialState> emit,
  ) async {
    emit(state.copyWith(checkStatus: StateLoading()));
    
    try {
      final isEligible = await _trialService.isEligibleForTrial();
      final trialStatus = await _trialService.getTrialStatus();
      
      emit(state.copyWith(
        checkStatus: const StateLoaded(successMessage: 'Trial eligibility checked'),
        isEligible: isEligible,
        trialStatus: trialStatus,
      ));
    } catch (e) {
      emit(state.copyWith(
        checkStatus: StateFailed(errorMessage: e.toString()),
        isEligible: false,
      ));
    }
  }

  Future<void> _onMarkTrialCompleted(
    MarkTrialCompleted event,
    Emitter<TrialState> emit,
  ) async {
    emit(state.copyWith(updateStatus: StateLoading()));
    
    try {
      await _trialService.markTrialCompleted();
      
      emit(state.copyWith(
        updateStatus: const StateLoaded(successMessage: 'Trial completed'),
        isEligible: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        updateStatus: StateFailed(errorMessage: e.toString()),
      ));
    }
  }
}
