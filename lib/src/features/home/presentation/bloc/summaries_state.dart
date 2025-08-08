part of 'summaries_bloc.dart';

class SummariesState {
  final List<SummaryWithDoctorName> summariesWithDoctorNames;
  final StateStatus fetchStatus;
  final bool hasMore;
  final bool isLoadingMore;
  final bool hasReachedEnd;

  SummariesState({
    this.summariesWithDoctorNames = const [],
    this.fetchStatus = const StateNotLoaded(),
    this.hasMore = true,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
  });

  SummariesState copyWith({
    List<SummaryWithDoctorName>? summariesWithDoctorNames,
    StateStatus? fetchStatus,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasReachedEnd,
  }) => SummariesState(
        summariesWithDoctorNames: summariesWithDoctorNames ?? this.summariesWithDoctorNames,
        fetchStatus: fetchStatus ?? this.fetchStatus,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      );
}
