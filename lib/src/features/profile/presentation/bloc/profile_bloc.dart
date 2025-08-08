import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../services/service_locator.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../data/model/doctor_model.dart';
import '../../domain/repo/profile_repo.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepo _profileRepo = serviceLocator<ProfileRepo>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileBloc() : super(ProfileState()) {
    on<FetchDoctorsEvent>((event, emit) async {
      if (event.isLoadMore) {
        emit(state.copyWith(isLoadingMore: true));
      } else {
        emit(state.copyWith(fetchDoctorListStatus: StateLoading()));
      }

      try {
        final User? currentUser = _auth.currentUser;
        if (currentUser == null) {
          emit(state.copyWith(
            fetchDoctorListStatus: StateFailed(errorMessage: 'User not authenticated'),
            isLoadingMore: false,
          ));
          return;
        }

        final doctors = await _profileRepo.getDoctors(
          currentUser.uid,
          lastDocument: event.lastDocument,
        );

        final updatedDoctors = event.lastDocument == null 
            ? doctors 
            : [...state.doctors, ...doctors];

        final hasMore = doctors.length == 10; // Assuming 10 is the limit
        // Only show "end of list" when we're loading more and get no new items
        final hasReachedEnd = event.isLoadMore && doctors.isEmpty && state.doctors.isNotEmpty;

        emit(state.copyWith(
          doctors: updatedDoctors,
          fetchDoctorListStatus: StateLoaded(successMessage: "Doctors fetched successfully"),
          hasMoreDoctors: hasMore,
          isLoadingMore: false,
          hasReachedEnd: hasReachedEnd,
        ));
      } catch (e) {
        emit(state.copyWith(
          fetchDoctorListStatus: StateFailed(errorMessage: e.toString()),
          isLoadingMore: false,
        ));
      }
    });

    on<AddDoctorEvent>((event, emit) async {
      emit(state.copyWith(addDoctorStatus: StateLoading()));

      try {
        final User? currentUser = _auth.currentUser;
        if (currentUser == null) {
          emit(state.copyWith(
            addDoctorStatus: StateFailed(errorMessage: 'User not authenticated'),
          ));
          return;
        }

        final doctor = DoctorModel(
          name: event.name,
          specialization: event.specialization,
          location: event.location.isNotEmpty ? event.location : null,
          patientId: currentUser.uid,
          createdAt: Timestamp.now(),
        );

        await _profileRepo.addDoctor(doctor);

        emit(state.copyWith(
          addDoctorStatus: StateLoaded(successMessage: 'Doctor added successfully'),
        ));
      } catch (e) {
        emit(state.copyWith(
          addDoctorStatus: StateFailed(errorMessage: e.toString()),
        ));
      }
    });

    on<UpdateDoctorEvent>((event, emit) async {
      emit(state.copyWith(updateDoctorStatus: StateLoading()));

      try {
        await _profileRepo.updateDoctor(event.doctor);

        emit(state.copyWith(
          updateDoctorStatus: StateLoaded(successMessage: 'Doctor updated successfully'),
        ));
      } catch (e) {
        emit(state.copyWith(
          updateDoctorStatus: StateFailed(errorMessage: e.toString()),
        ));
      }
    });

    on<DeleteDoctorEvent>((event, emit) async {
      emit(state.copyWith(deleteDoctorStatus: StateLoading()));

      try {
        await _profileRepo.deleteDoctor(event.doctorId);

        // Remove from local list
        final updatedDoctors = state.doctors.where((d) => d.id != event.doctorId).toList();

        emit(state.copyWith(
          doctors: updatedDoctors,
          deleteDoctorStatus: StateLoaded(successMessage: 'Doctor deleted successfully'),
        ));
      } catch (e) {
        emit(state.copyWith(
          deleteDoctorStatus: StateFailed(errorMessage: e.toString()),
        ));
      }
    });

    on<ClearDoctorStatusEvent>((event, emit) {
      emit(state.copyWith(
        addDoctorStatus: const StateNotLoaded(),
        updateDoctorStatus: const StateNotLoaded(),
        deleteDoctorStatus: const StateNotLoaded(),
      ));
    });
  }
}
