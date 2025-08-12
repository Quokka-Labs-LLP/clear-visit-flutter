part of 'summaries_bloc.dart';

class SummariesState {
  final List<SummaryWithDoctorName> summariesWithDoctorNames;
  final StateStatus fetchStatus;
  final bool hasMore;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final bool isLoadingTranscription;
  final String? summaryText;
  final List<String>? followUpQuestions;
  final String? errorMessage;
  final bool isLoading;
  final bool isPlaying;
  final Duration duration;
  final Duration currentPosition;
  final String? playingAudioError;
  final String? recordingUrl;
  final String? recordingStatus;
  final StateStatus audioLoadStatus;

  SummariesState({
    this.summariesWithDoctorNames = const [],
    this.fetchStatus = const StateNotLoaded(),
    this.audioLoadStatus = const StateNotLoaded(),
    this.hasMore = true,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.isLoadingTranscription = false,
    this.summaryText,
    this.followUpQuestions,
    this.errorMessage,
    this.isLoading = false,
    this.isPlaying = false,
    this.duration = Duration.zero,
    this.currentPosition = Duration.zero,
    this.playingAudioError,
    this.recordingUrl,
    this.recordingStatus,
  });

  SummariesState copyWith({
    List<SummaryWithDoctorName>? summariesWithDoctorNames,
    StateStatus? fetchStatus,
    StateStatus? audioLoadStatus,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    bool? isLoadingTranscription,
    String? summaryText,
    List<String>? followUpQuestions,
    String? recordingUrl,
    String? errorMessage,
    bool? isLoading,
    bool? isPlaying,
    Duration? duration,
    Duration? currentPosition,
    String? playingAudioError,
    String? recordingStatus,
  }) => SummariesState(
    summariesWithDoctorNames:
        summariesWithDoctorNames ?? this.summariesWithDoctorNames,
    fetchStatus: fetchStatus ?? this.fetchStatus,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    isLoadingTranscription:
        isLoadingTranscription ?? this.isLoadingTranscription,
    summaryText: summaryText ?? this.summaryText,
    followUpQuestions: followUpQuestions ?? this.followUpQuestions,
    errorMessage: errorMessage ?? this.errorMessage,
    isLoading: isLoading ?? this.isLoading,
    isPlaying: isPlaying ?? this.isPlaying,
    duration: duration ?? this.duration,
    currentPosition: currentPosition ?? this.currentPosition,
    playingAudioError: playingAudioError ?? this.playingAudioError,
    audioLoadStatus: audioLoadStatus ?? this.audioLoadStatus,
    recordingUrl: recordingUrl ?? this.recordingUrl,
    recordingStatus: recordingStatus ?? this.recordingStatus,
  );
}
