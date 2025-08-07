part of 'home_bloc.dart';

class HomeState {
  final StateStatus addDoctorStatus;

  HomeState({
    this.addDoctorStatus = const StateNotLoaded(),
  });

  HomeState copyWith({
    StateStatus? addDoctorStatus,
  }) => HomeState(
    addDoctorStatus: addDoctorStatus ?? this.addDoctorStatus,
  );
} 