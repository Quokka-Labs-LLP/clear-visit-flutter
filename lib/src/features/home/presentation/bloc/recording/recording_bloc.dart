import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../services/trial_service.dart';

part 'recording_event.dart';
part 'recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final AudioRecorder _recorder = AudioRecorder();
  final TrialService _trialService = TrialService();
  StreamSubscription<RecordState>? _recordSub;
  StreamSubscription<Amplitude>? _ampSub;
  Timer? _timer;
  Timer? _trialTimer;
  bool _speechDetected = false;
  bool _isTrialMode = false;

  RecordingBloc() : super(const RecordingState()) {
    on<RecordingInitialize>(_onInitialize);
    on<RecordingRequestPermission>(_onRequestPermission);
    on<RecordingStart>(_onStart);
    on<RecordingStartTrial>(_onStartTrial);
    on<RecordingStop>(_onStop);
    on<RecordingNavigationHandled>(_onNavigationHandled);
    on<RecordingPauseOrResume>(_onPauseOrResume);
    on<RecordingTick>(_onRecordingTick);
  }

  Future<void> _onInitialize(
    RecordingInitialize event,
    Emitter<RecordingState> emit,
  ) async {
    // Ensure permission check only; do not mirror recorder internal state to bloc events
    await _onRequestPermission(const RecordingRequestPermission(), emit);
  }

  Future<void> _onRequestPermission(
    RecordingRequestPermission event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      final hasViaRecord = await _recorder.hasPermission();
      if (hasViaRecord) {
        emit(state.copyWith(permissionStatus: MicPermissionStatus.granted));
        return;
      }

      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }

      if (status.isGranted) {
        emit(state.copyWith(permissionStatus: MicPermissionStatus.granted));
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        emit(
          state.copyWith(
            permissionStatus: MicPermissionStatus.permanentlyDenied,
          ),
        );
      } else {
        emit(state.copyWith(permissionStatus: MicPermissionStatus.denied));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<String> _generateFilePath() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory recordingsDir = Directory('${appDocDir.path}/recordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '${recordingsDir.path}/visit_$timestamp.m4a';
  }

  static Future<void> _writeBytesIsolate(Map<String, dynamic> params) async {
    final String path = params['path'] as String;
    final List<int> bytes = params['bytes'] as List<int>;
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<void> _onStartTrial(
    RecordingStartTrial event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      if (state.permissionStatus != MicPermissionStatus.granted) {
        await _onRequestPermission(const RecordingRequestPermission(), emit);
        if (state.permissionStatus != MicPermissionStatus.granted) {
          return;
        }
      }

      if (await _recorder.isRecording()) {
        return; // already recording
      }

      final path = await _generateFilePath();
      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );
      await _recorder.start(config, path: path);
      _timer?.cancel();
      _ampSub?.cancel();
      _speechDetected = false;
      _isTrialMode = true;
      
      _ampSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 300))
          .listen((amp) {
        // Amplitude in dBFS (negative). Values closer to 0 are louder
        // Mark speech detected if above threshold
        if (amp.current > -40) {
          _speechDetected = true;
        }
      });

      emit(
        state.copyWith(
          isRecording: true,
          filePath: path,
          isPaused: false,
          recordingDuration: Duration.zero,
          elapsedSeconds: 0,
        ),
      );
      _startTimer();
      
      // Start trial timer - auto-stop at 59 seconds
      _trialTimer?.cancel();
      _trialTimer = Timer(const Duration(seconds: 59), () {
        if (_isTrialMode && state.isRecording) {
          add(const RecordingStop());
        }
      });
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onStart(
    RecordingStart event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      if (state.permissionStatus != MicPermissionStatus.granted) {
        await _onRequestPermission(const RecordingRequestPermission(), emit);
        if (state.permissionStatus != MicPermissionStatus.granted) {
          return;
        }
      }

      if (await _recorder.isRecording()) {
        return; // already recording
      }

      final path = await _generateFilePath();
      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );
      await _recorder.start(config, path: path);
      _timer?.cancel();
      _ampSub?.cancel();
      _speechDetected = false;
      _ampSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 300))
          .listen((amp) {
        // Amplitude in dBFS (negative). Values closer to 0 are louder
        // Mark speech detected if above threshold
        if (amp.current > -40) {
          _speechDetected = true;
        }
      });

      emit(
        state.copyWith(
          isRecording: true,
          filePath: path,
          isPaused: false,
          recordingDuration: Duration.zero,
          elapsedSeconds: 0,
        ),
      );
      _startTimer();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onStop(
    RecordingStop event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      final path = await _recorder.stop();
      _timer?.cancel();
      _trialTimer?.cancel();
      await _ampSub?.cancel();

      String? finalPath = path ?? state.filePath;
      if (finalPath != null) {
        final file = File(finalPath);
        if (await file.exists()) {
          // Basic blank recording check by size
          final fileSize = await file.length();
          final isTooSmall = fileSize < 2000; // ~2KB threshold
          final isBlank = !_speechDetected || isTooSmall;

          if (isBlank) {
            // Clean up and notify once
            try { await file.delete(); } catch (_) {}
            emit(state.copyWith(
              isRecording: false,
              isPaused: false,
              errorMessage: 'Nothing is recorded, please try again',
            ));
            // Clear the error after showing it once
            await Future<void>.delayed(const Duration(milliseconds: 10));
            emit(state.copyWith(errorMessage: null));
            return;
          } else {
            final bytes = await file.readAsBytes();
            await compute(_writeBytesIsolate, {
              'path': finalPath,
              'bytes': bytes,
            });
          }
        }
      }
      // If this was a trial recording, mark it as completed
      if (_isTrialMode) {
        await _trialService.markTrialCompleted();
        _isTrialMode = false;
      }
      
      emit(state.copyWith(isRecording: false, isPaused: false, completedFilePath: finalPath));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onPauseOrResume(
      RecordingPauseOrResume event,
      Emitter<RecordingState> emit,
      ) async {
    try {
      if (state.isRecording) {
        // Pause
        await _recorder.pause();
        _timer?.cancel();
        emit(state.copyWith(isPaused: true, isRecording: false));
      }
      else if (state.isPaused) {
        // Resume
        await _recorder.resume();

        // Continue timer from where it left off
        _startTimer();

        emit(state.copyWith(isPaused: false, isRecording: true));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }




  void _onNavigationHandled(
    RecordingNavigationHandled event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(completedFilePath: null));
  }

  void _onRecordingTick(RecordingTick event, Emitter<RecordingState> emit) {
    if (state.isRecording) {
      emit(
        state.copyWith(
          elapsedSeconds: state.elapsedSeconds + 1,
          recordingDuration: state.recordingDuration + const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _trialTimer?.cancel();
    _recordSub?.cancel();
    _ampSub?.cancel();
    _recorder.dispose();
    return super.close();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const RecordingTick());
    });
  }
}
