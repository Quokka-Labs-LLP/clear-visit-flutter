import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:base_architecture/src/features/home/data/model/summary_with_doc_model.dart';
import 'package:base_architecture/src/services/service_locator.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:share_plus/share_plus.dart';

import '../../../../shared/utilities/event_status.dart';
import '../../../../shared/utilities/pdf_generator.dart';
import '../../data/model/summary_model.dart';
import '../../domain/repo/summary_repo.dart';

part 'summaries_event.dart';
part 'summaries_state.dart';

class SummariesBloc extends Bloc<SummariesEvent, SummariesState> {
  final FirebaseAuth _auth = serviceLocator<FirebaseAuth>();
  final SummaryRepo summaryRepo = serviceLocator<SummaryRepo>();
  final _player = AudioPlayer();
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  SummariesBloc() : super( SummariesState()) {
    on<FetchSummariesEvent>(_onFetchSummariesEvent);
    on<StartTranscriptionEvent>(_onStartTranscriptionEvent);
    on<GetSummaryDetailsEvent>(_onGetSummaryDetailsEvent);
    on<LoadAudioEvent>(_onLoadAudio);
    on<PlayAudioEvent>(_onPlay);
    on<PauseAudioEvent>(_onPause);
    on<StopAudioEvent>(_onStop);
    on<PositionChanged>(_onPositionChanged);
    on<PlayerStateChanged>(_onPlayerStateChanged);
    on<ShareSummary>(_onShareSummary);

    // Listen to position updates from the player
    _positionSubscription = _player.positionStream.listen((pos) {
      if (!isClosed) {
        add(PositionChanged(pos));
      }
    });

    // Listen to player state changes to sync UI with actual player state
    _playerStateSubscription = _player.playerStateStream.listen((playerState) {
      if (!isClosed) {
        add(PlayerStateChanged(playerState));
      }
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
            final doctorName = await summaryRepo.getDoctorName(summary.doctorId??"");
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
        emit(state.copyWith(isLoadingTranscription: false, summaryModel: SummaryModel(
            title: 'Visit Summary',
            recordingPath: event.localFilePath,
            createdAt: Timestamp.now(),
            uploadStatus: 'pending',
          summaryText: result.summaryText,
          followUpQuestions: result.followUpQuestions,
          doctorName: event.doctorName,
        )));
      } catch (e) {
        // Map conversation/blank specific errors to one-time message
        final message = e.toString();
        String uiMessage = message;
        if (message.contains('No conversation recorded') || message.contains('No recording found')) {
          uiMessage = message.contains('No conversation recorded')
              ? 'No conversation recorded, please try again'
              : 'No recording found, please try again';
        }
        emit(state.copyWith(isLoadingTranscription: false, errorMessage: uiMessage));
        // Clear after first display to avoid repeat snackbars
        await Future<void>.delayed(const Duration(milliseconds: 10));
        emit(state.copyWith(errorMessage: null));
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
        if(summary.doctorId != null && summary.doctorId!.isNotEmpty) {
        final doctorName = await summaryRepo.getDoctorName(summary.doctorId??"");
        emit(state.copyWith(
            isLoadingTranscription: false,
            summaryModel: summary.copyWith(doctorName: doctorName??"Doctor"),
          recordingStatus:summary.uploadStatus,

        ));
        add(LoadAudioEvent(remoteUrl: summary.recordingUrl));}
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
          // Download to temp dir with progress
          final tempDir = await getTemporaryDirectory();
          final localFile = File('${tempDir.path}/downloaded_audio.mp3');

          emit(state.copyWith(audioDownloadProgress: 0.0));

          final client = http.Client();
          try {
            final request = http.Request('GET', Uri.parse(event.remoteUrl!));
            final streamedResponse = await client.send(request);
            final contentLength = streamedResponse.contentLength ?? 0;

            final fileSink = localFile.openWrite();
            int bytesReceived = 0;

            await for (final chunk in streamedResponse.stream) {
              if (isClosed) {
                await fileSink.close();
                client.close();
                return;
              }
              bytesReceived += chunk.length;
              fileSink.add(chunk);

              if (contentLength > 0) {
                final progress = bytesReceived / contentLength;
                emit(state.copyWith(audioDownloadProgress: progress.clamp(0.0, 1.0)));
              }
            }

            await fileSink.close();
            sourcePath = localFile.path;

            // Ensure progress shows as complete when done
            emit(state.copyWith(audioDownloadProgress: 1.0));
          } finally {
            client.close();
          }
        } else {
          throw Exception("No audio source provided");
        }

        if (isClosed) {
          return;
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

    void _onPlayerStateChanged(
        PlayerStateChanged event, Emitter<SummariesState> emit) {
      final isPlaying = event.playerState.playing;
      final processingState = event.playerState.processingState;
      
      // Update the playing state based on actual player state
      emit(state.copyWith(isPlaying: isPlaying));
      
      // Handle completion - reset position when audio completes
      if (processingState == ProcessingState.completed) {
        emit(state.copyWith(
          isPlaying: false,
          currentPosition: Duration.zero,
        ));
      }
    }

    @override
    Future<void> close() {
      _positionSubscription?.cancel();
      _playerStateSubscription?.cancel();
      _player.dispose();
      return super.close();
    }


  FutureOr<void> _onShareSummary(ShareSummary event, Emitter<SummariesState> emit) async {
    emit(state.copyWith(shareSummaryStatus: StateLoading()));
    try {
      final token = RootIsolateToken.instance!;
      final pdfFile = await compute(pdfWorker, PdfParams(event.imageBytes, token));
      await Share.shareXFiles([XFile(pdfFile.path)], text: 'Visit summary attached.');
      emit(state.copyWith(shareSummaryStatus: StateLoaded(successMessage: 'Summary shared successfully')));
    } catch (e) {
      debugPrint('Error sharing summary: $e');
      emit(state.copyWith(shareSummaryStatus: StateFailed(errorMessage: e.toString())));
    }
  }
}


