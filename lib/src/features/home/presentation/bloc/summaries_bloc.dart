import 'package:base_architecture/src/features/home/data/model/summary_with_doc_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../shared/utilities/event_status.dart';
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
    on<StartTranscriptionEvent>((event, emit) async{
      try {
        emit(state.copyWith(isLoadingTranscription: true, errorMessage: null));

        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        final result = await _repo.createSummaryFromRecording(
          patientId: user.uid,
          doctorId: event.doctorId ?? '',
          filePath: event.localFilePath!,
        );
        emit(state.copyWith(isLoadingTranscription: false, summaryText: result.summaryText, followUpQuestions: result.followUpQuestions));
      } catch (e) {
        emit(state.copyWith(
          isLoadingTranscription: false,
          errorMessage: e.toString(),
        ));
      }
    });

    on<GetSummaryDetailsEvent>((event, emit) async{
      emit(state.copyWith(isLoadingTranscription: true, errorMessage: null));
      try {
        final summary = await _repo.getSummaryById(event.summaryId);
        if (summary == null) {
          emit(state.copyWith(isLoadingTranscription: false, errorMessage: 'Summary not found'));
          return;
        }
        // final doctorName = await _repo.getDoctorName(summary.doctorId) ?? 'Unknown Doctor';
        emit(state.copyWith(
          isLoadingTranscription: false,
          summaryText: summary.summaryText ?? '',
          followUpQuestions: summary.followUpQuestions
        ));
      } catch (e) {
        emit(state.copyWith(isLoadingTranscription: false, errorMessage: e.toString()));
      }
    });
  }
}


