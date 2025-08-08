import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../shared/utilities/event_status.dart';
import '../../data/model/summary_model.dart';
import '../../data/repo_impl/summary_repo_impl.dart';
import '../../domain/repo/summary_repo.dart';

part 'summaries_event.dart';
part 'summaries_state.dart';

class SummariesBloc extends Bloc<SummariesEvent, SummariesState> {
  final SummaryRepo _repo;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SummariesBloc({SummaryRepo? repo})
      : _repo = repo ?? SummaryRepoImpl(),
        super(SummariesState()) {
    on<FetchSummariesEvent>((event, emit) async {
      if (event.isLoadMore) {
        emit(state.copyWith(isLoadingMore: true));
      } else {
        emit(state.copyWith(fetchStatus: StateLoading()));
      }

      final user = _auth.currentUser;
      if (user == null) {
        emit(state.copyWith(
          fetchStatus: StateFailed(errorMessage: 'User not authenticated'),
          isLoadingMore: false,
        ));
        return;
      }

      try {
        final summaries = await _repo.getSummaries(user.uid, lastDocument: event.lastDocument);
        
        // Resolve doctor names for new summaries
        final summariesWithDoctorNames = await Future.wait(
          summaries.map((summary) async {
            final doctorName = await _repo.getDoctorName(summary.doctorId);
            return SummaryWithDoctorName(
              summary: summary,
              doctorName: doctorName ?? 'Unknown Doctor',
            );
          }),
        );

        final updated = event.lastDocument == null 
            ? summariesWithDoctorNames 
            : [...state.summariesWithDoctorNames, ...summariesWithDoctorNames];
        
        final hasMore = summaries.length == 10;
        final reachedEnd = event.isLoadMore && summaries.isEmpty && state.summariesWithDoctorNames.isNotEmpty;

        emit(state.copyWith(
          summariesWithDoctorNames: updated,
          fetchStatus: StateLoaded(successMessage: 'Summaries loaded successfully'),
          hasMore: hasMore,
          isLoadingMore: false,
          hasReachedEnd: reachedEnd,
        ));
      } catch (e) {
        emit(state.copyWith(
          fetchStatus: StateFailed(errorMessage: e.toString()),
          isLoadingMore: false,
        ));
      }
    });
  }
}

class SummaryWithDoctorName {
  final SummaryModel summary;
  final String doctorName;

  SummaryWithDoctorName({
    required this.summary,
    required this.doctorName,
  });
}
