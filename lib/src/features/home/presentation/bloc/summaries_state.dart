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

  SummariesState({
    this.summariesWithDoctorNames = const [],
    this.fetchStatus = const StateNotLoaded(),
    this.hasMore = true,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.isLoadingTranscription = false,
    this.summaryText,
    this.followUpQuestions,
    this.errorMessage,
  });

  SummariesState copyWith({
    List<SummaryWithDoctorName>? summariesWithDoctorNames,
    StateStatus? fetchStatus,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    bool? isLoadingTranscription,
    String? summaryText,
    List<String>? followUpQuestions,
    String? errorMessage,
  }) => SummariesState(
        summariesWithDoctorNames: summariesWithDoctorNames ?? this.summariesWithDoctorNames,
        fetchStatus: fetchStatus ?? this.fetchStatus,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    isLoadingTranscription: isLoadingTranscription ?? this.isLoadingTranscription,
    summaryText: summaryText ?? this.summaryText,
    followUpQuestions: followUpQuestions ?? this.followUpQuestions,
    errorMessage: errorMessage,
      );
}
