part of 'trial_bloc.dart';

abstract class TrialEvent extends Equatable {
  const TrialEvent();

  @override
  List<Object?> get props => [];
}

class CheckTrialEligibility extends TrialEvent {
  const CheckTrialEligibility();
}

class MarkTrialCompleted extends TrialEvent {
  const MarkTrialCompleted();
}
