part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class FetchDoctorsEvent extends ProfileEvent {
  final DocumentSnapshot? lastDocument;
  final bool isLoadMore;

  const FetchDoctorsEvent({
    this.lastDocument,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [lastDocument, isLoadMore];
}

class AddDoctorEvent extends ProfileEvent {
  final String name;
  final String specialization;
  final String location;

  const AddDoctorEvent({
    required this.name,
    required this.specialization,
    required this.location,
  });

  @override
  List<Object?> get props => [name, specialization, location];
}

class UpdateDoctorEvent extends ProfileEvent {
  final DoctorModel doctor;

  const UpdateDoctorEvent({required this.doctor});

  @override
  List<Object?> get props => [doctor];
}

class DeleteDoctorEvent extends ProfileEvent {
  final String doctorId;

  const DeleteDoctorEvent({required this.doctorId});

  @override
  List<Object?> get props => [doctorId];
}

class ClearDoctorStatusEvent extends ProfileEvent {
  const ClearDoctorStatusEvent();

  @override
  List<Object?> get props => [];
}
