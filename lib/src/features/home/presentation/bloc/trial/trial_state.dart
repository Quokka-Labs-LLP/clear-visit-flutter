part of 'trial_bloc.dart';

class TrialState extends Equatable {
  final bool isEligible;
  final Map<String, dynamic>? trialStatus;
  final StateStatus checkStatus;
  final StateStatus updateStatus;

  const TrialState({
    this.isEligible = false,
    this.trialStatus,
    this.checkStatus = const StateNotLoaded(),
    this.updateStatus = const StateNotLoaded(),
  });

  TrialState copyWith({
    bool? isEligible,
    Map<String, dynamic>? trialStatus,
    StateStatus? checkStatus,
    StateStatus? updateStatus,
  }) {
    return TrialState(
      isEligible: isEligible ?? this.isEligible,
      trialStatus: trialStatus ?? this.trialStatus,
      checkStatus: checkStatus ?? this.checkStatus,
      updateStatus: updateStatus ?? this.updateStatus,
    );
  }

  @override
  List<Object?> get props => [
    isEligible,
    trialStatus,
    checkStatus,
    updateStatus,
  ];
}
