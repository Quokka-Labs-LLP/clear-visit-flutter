part of 'summaries_bloc.dart';

class SummariesState {
  final List<SummaryWithDoctorName> summariesWithDoctorNames;
  final StateStatus fetchStatus;
  final bool hasMore;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final bool isLoadingTranscription;
  final String? errorMessage;
  final bool isLoading;
  final bool isPlaying;
  final SummaryModel? summaryModel;
  final Duration duration;
  final Duration currentPosition;
  final String? playingAudioError;
  final String? recordingStatus;
  final StateStatus audioLoadStatus;
  final StateStatus shareSummaryStatus;
  final double audioDownloadProgress;

  SummariesState({
    this.summariesWithDoctorNames = const [],
    this.fetchStatus = const StateNotLoaded(),
    this.audioLoadStatus = const StateNotLoaded(),
    this.hasMore = true,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.isLoadingTranscription = false,
this.summaryModel,
    this.errorMessage,
    this.isLoading = false,
    this.isPlaying = false,
    this.duration = Duration.zero,
    this.currentPosition = Duration.zero,
    this.playingAudioError,
    this.recordingStatus,
    this.shareSummaryStatus = const StateNotLoaded(),
    this.audioDownloadProgress = 0.0,
  });

  SummariesState copyWith({
    List<SummaryWithDoctorName>? summariesWithDoctorNames,
    StateStatus? fetchStatus,
    StateStatus? audioLoadStatus,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    bool? isLoadingTranscription,
    SummaryModel? summaryModel,
    String? errorMessage,
    bool? isLoading,
    bool? isPlaying,
    Duration? duration,
    Duration? currentPosition,
    String? playingAudioError,
    String? recordingStatus,
    StateStatus? shareSummaryStatus,
    double? audioDownloadProgress,
  }) => SummariesState(
    summariesWithDoctorNames:
        summariesWithDoctorNames ?? this.summariesWithDoctorNames,
    fetchStatus: fetchStatus ?? this.fetchStatus,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    isLoadingTranscription:
        isLoadingTranscription ?? this.isLoadingTranscription,
    errorMessage: errorMessage ?? this.errorMessage,
    isLoading: isLoading ?? this.isLoading,
    isPlaying: isPlaying ?? this.isPlaying,
    duration: duration ?? this.duration,
    currentPosition: currentPosition ?? this.currentPosition,
    playingAudioError: playingAudioError ?? this.playingAudioError,
    audioLoadStatus: audioLoadStatus ?? this.audioLoadStatus,
    recordingStatus: recordingStatus ?? this.recordingStatus,
    shareSummaryStatus: shareSummaryStatus ?? this.shareSummaryStatus,
    summaryModel: summaryModel ?? this.summaryModel,
    audioDownloadProgress: audioDownloadProgress ?? this.audioDownloadProgress,
  );
}
