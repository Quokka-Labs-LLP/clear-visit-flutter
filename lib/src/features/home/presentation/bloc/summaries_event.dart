part of 'summaries_bloc.dart';

abstract class SummariesEvent extends Equatable {
  const SummariesEvent();
}

class FetchSummariesEvent extends SummariesEvent {
  final DocumentSnapshot? lastDocument;
  final bool isLoadMore;

  const FetchSummariesEvent({this.lastDocument, this.isLoadMore = false});

  @override
  List<Object?> get props => [lastDocument, isLoadMore];
}
class StartTranscriptionEvent extends SummariesEvent {
  final String? localFilePath;
  final String? doctorId;

  const StartTranscriptionEvent({this.localFilePath, this.doctorId});

  @override
  List<Object?> get props => [localFilePath, doctorId];
}

class GetSummaryDetailsEvent extends SummariesEvent {
  final String summaryId;
  const GetSummaryDetailsEvent(this.summaryId);

  @override
  List<Object?> get props => [summaryId];
}


