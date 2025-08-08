part of 'profile_bloc.dart';

class ProfileState {
  final List<DoctorModel> doctors;
  final StateStatus fetchDoctorListStatus;
  final StateStatus addDoctorStatus;
  final StateStatus updateDoctorStatus;
  final StateStatus deleteDoctorStatus;
  final bool hasMoreDoctors;
  final bool isLoadingMore;
  final bool hasReachedEnd;

  ProfileState({
    this.doctors = const [],
    this.fetchDoctorListStatus = const StateNotLoaded(),
    this.addDoctorStatus = const StateNotLoaded(),
    this.updateDoctorStatus = const StateNotLoaded(),
    this.deleteDoctorStatus = const StateNotLoaded(),
    this.hasMoreDoctors = true,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
  });

  ProfileState copyWith({
    List<DoctorModel>? doctors,
    StateStatus? fetchDoctorListStatus,
    StateStatus? addDoctorStatus,
    StateStatus? updateDoctorStatus,
    StateStatus? deleteDoctorStatus,
    bool? hasMoreDoctors,
    bool? isLoadingMore,
    bool? hasReachedEnd,
  }) {
    return ProfileState(
      doctors: doctors ?? this.doctors,
      fetchDoctorListStatus: fetchDoctorListStatus ?? this.fetchDoctorListStatus,
      addDoctorStatus: addDoctorStatus ?? this.addDoctorStatus,
      updateDoctorStatus: updateDoctorStatus ?? this.updateDoctorStatus,
      deleteDoctorStatus: deleteDoctorStatus ?? this.deleteDoctorStatus,
      hasMoreDoctors: hasMoreDoctors ?? this.hasMoreDoctors,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}
