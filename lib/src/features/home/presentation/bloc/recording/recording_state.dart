part of 'recording_bloc.dart';

enum MicPermissionStatus { unknown, granted, denied, permanentlyDenied }

class RecordingState extends Equatable {
  final MicPermissionStatus permissionStatus;
  final bool isRecording;
  final String? filePath;
  final String? completedFilePath;
  final String? errorMessage;
  final bool isPaused;
  final Duration recordingDuration;
  final int elapsedSeconds;


  const RecordingState({
    this.permissionStatus = MicPermissionStatus.unknown,
    this.isRecording = false,
    this.filePath,
    this.completedFilePath,
    this.errorMessage,
    this.isPaused = false,
    this.recordingDuration = Duration.zero,
    this.elapsedSeconds = 0,

  });

  RecordingState copyWith({
    MicPermissionStatus? permissionStatus,
    bool? isRecording,
    String? filePath,
    String? completedFilePath,
    String? errorMessage,
    bool? isPaused,
    Duration? recordingDuration,
    int? elapsedSeconds,
  }) {
    return RecordingState(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isRecording: isRecording ?? this.isRecording,
      filePath: filePath ?? this.filePath,
      completedFilePath: completedFilePath ?? this.completedFilePath,
      errorMessage: errorMessage?? this.errorMessage,
      isPaused: isPaused ?? this.isPaused,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  @override
  List<Object?> get props => [
    permissionStatus,
    isRecording,
    filePath,
    completedFilePath,
    errorMessage,
    isPaused,
    recordingDuration,
    elapsedSeconds
  ];
}
