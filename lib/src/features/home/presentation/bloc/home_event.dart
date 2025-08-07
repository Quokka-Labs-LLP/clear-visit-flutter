part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class OnAddDoctorEvent extends HomeEvent {
  final String name;
  final String specialization;
  final String location;

  const OnAddDoctorEvent({
    required this.name,
    required this.specialization,
    required this.location,
  });

  @override
  List<Object?> get props => [name, specialization, location];
} 