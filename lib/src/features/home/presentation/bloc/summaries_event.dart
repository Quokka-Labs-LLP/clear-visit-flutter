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
