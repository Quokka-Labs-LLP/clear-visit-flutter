import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../services/service_locator.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../../../shared_pref_services/shared_pref_base_service.dart';
import '../../../../shared_pref_services/shared_pref_keys.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseFirestore _firestore = serviceLocator<FirebaseFirestore>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HomeBloc() : super(HomeState()) {
    on<OnAddDoctorEvent>((event, emit) async {
      emit(state.copyWith(addDoctorStatus: StateLoading()));

      try {
        final User? currentUser = _auth.currentUser;
        if (currentUser == null) {
          emit(state.copyWith(
            addDoctorStatus: StateFailed(errorMessage: 'User not authenticated'),
          ));
          return;
        }

        await _firestore.collection('doctors').add({
          'name': event.name,
          'specialization': event.specialization,
          'location': event.location.isNotEmpty ? event.location : null,
          'patientId': currentUser.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        emit(state.copyWith(
          addDoctorStatus: StateLoaded(successMessage: 'Doctor added successfully'),
        ));
      } catch (e) {
        emit(state.copyWith(
          addDoctorStatus: StateFailed(errorMessage: 'Failed to add doctor: ${e.toString()}'),
        ));
      }
    });
  }
} 