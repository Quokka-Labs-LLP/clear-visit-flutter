import 'dart:io';

import 'package:base_architecture/src/features/home/data/model/summary_with_doc_model.dart';
import 'package:base_architecture/src/services/service_locator.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../shared/utilities/event_status.dart';
import '../../domain/repo/summary_repo.dart';

part 'summaries_event.dart';
part 'summaries_state.dart';

class SummariesBloc extends Bloc<SummariesEvent, SummariesState> {
  final FirebaseAuth _auth = serviceLocator<FirebaseAuth>();
  final SummaryRepo summaryRepo = serviceLocator<SummaryRepo>();
  final _player = AudioPlayer();

  SummariesBloc() : super( SummariesState()) {
    on<FetchSummariesEvent>(_onFetchSummariesEvent);
    on<StartTranscriptionEvent>(_onStartTranscriptionEvent);
    on<GetSummaryDetailsEvent>(_onGetSummaryDetailsEvent);
    on<LoadAudioEvent>(_onLoadAudio);
    on<PlayAudioEvent>(_onPlay);
    on<PauseAudioEvent>(_onPause);
    on<StopAudioEvent>(_onStop);
    on<PositionChanged>(_onPositionChanged);

    // Listen to position updates from the player
    _player.positionStream.listen((pos) {
      add(PositionChanged(pos));
    });
  }
  Future<void> _onFetchSummariesEvent(
      FetchSummariesEvent event, Emitter<SummariesState> emit) async{
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
        final summaries = await summaryRepo.getSummaries(user.uid, lastDocument: event.lastDocument);

        // Resolve doctor names for new summaries
        final summariesWithDoctorNames = await Future.wait(
          summaries.map((summary) async {
            final doctorName = await summaryRepo.getDoctorName(summary.doctorId);
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
    }
  Future<void> _onStartTranscriptionEvent(
  StartTranscriptionEvent event, Emitter<SummariesState> emit) async{
      try {
        emit(state.copyWith(isLoadingTranscription: true, errorMessage: null));

        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        final result = await summaryRepo.createSummaryFromRecording(
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
    }

  Future<void> _onGetSummaryDetailsEvent(
  GetSummaryDetailsEvent event, Emitter<SummariesState> emit) async{
      emit(state.copyWith(isLoadingTranscription: true, errorMessage: null));
      try {
        final summary = await summaryRepo.getSummaryById(event.summaryId);
        if (summary == null) {
          emit(state.copyWith(isLoadingTranscription: false, errorMessage: 'Summary not found'));
          return;
        }
        emit(state.copyWith(
            isLoadingTranscription: false,
            summaryText: summary.summaryText ?? '',
            followUpQuestions: summary.followUpQuestions,
            recordingUrl:summary.recordingUrl,
          recordingStatus:summary.uploadStatus,

        ));
        add(LoadAudioEvent(remoteUrl: summary.recordingUrl));
      } catch (e) {
        emit(state.copyWith(isLoadingTranscription: false, errorMessage: e.toString()));
      }
    }

    Future<void> _onLoadAudio(
        LoadAudioEvent event, Emitter<SummariesState> emit) async {
      emit(state.copyWith(audioLoadStatus: StateLoading(), errorMessage: null));

      try {
        String sourcePath;
        if (event.localPath != null && File(event.localPath!).existsSync()) {
          sourcePath = event.localPath!;
        } else if (event.remoteUrl != null) {
          // Download to temp dir
          final tempDir = await getTemporaryDirectory();
          final localFile = File('${tempDir.path}/downloaded_audio.mp3');
          final response = await http.get(Uri.parse(event.remoteUrl!));
          await localFile.writeAsBytes(response.bodyBytes);
          sourcePath = localFile.path;
        } else {
          throw Exception("No audio source provided");
        }

        await _player.setFilePath(sourcePath);
        emit(state.copyWith(
          audioLoadStatus: StateLoaded(successMessage: 'Audio loaded successfully'),
          duration: _player.duration ?? Duration.zero,
          currentPosition: Duration.zero,
          isPlaying: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          audioLoadStatus: StateFailed(errorMessage: e.toString()),
          errorMessage: e.toString(),
        ));
      }
    }

    Future<void> _onPlay(PlayAudioEvent event, Emitter<SummariesState> emit) async {
      await _player.play();
      emit(state.copyWith(isPlaying: true));
    }

    Future<void> _onPause(PauseAudioEvent event, Emitter<SummariesState> emit) async {
      await _player.pause();
      emit(state.copyWith(isPlaying: false));
    }

    Future<void> _onStop(StopAudioEvent event, Emitter<SummariesState> emit) async {
      await _player.stop();
      emit(state.copyWith(
        isPlaying: false,
        currentPosition: Duration.zero,
      ));
    }

    void _onPositionChanged(
        PositionChanged event, Emitter<SummariesState> emit) {
      emit(state.copyWith(currentPosition: event.position));
    }

    @override
    Future<void> close() {
      _player.dispose();
      return super.close();
    }

}


