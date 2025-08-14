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
  final String? doctorName;

  const StartTranscriptionEvent({this.localFilePath, this.doctorId, this.doctorName});

  @override
  List<Object?> get props => [localFilePath, doctorId];
}

class GetSummaryDetailsEvent extends SummariesEvent {
  final String summaryId;
  const GetSummaryDetailsEvent(this.summaryId);

  @override
  List<Object?> get props => [summaryId];
}

class LoadAudioEvent extends SummariesEvent {
  final String? localPath;
  final String? remoteUrl;
  const LoadAudioEvent({this.localPath, this.remoteUrl});

  @override
  List<Object?> get props => [localPath, remoteUrl];
}

class PlayAudioEvent extends SummariesEvent {
  @override
  List<Object?> get props => [];
}

class PauseAudioEvent extends SummariesEvent {
  @override
  List<Object?> get props => [];
}

class StopAudioEvent extends SummariesEvent {
  @override
  List<Object?> get props => [];
}

class PositionChanged extends SummariesEvent {
  final Duration position;
  const PositionChanged(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayerStateChanged extends SummariesEvent {
  final PlayerState playerState;
  const PlayerStateChanged(this.playerState);

  @override
  List<Object?> get props => [playerState];
}

class ShareSummary extends SummariesEvent {
  final Uint8List imageBytes;
  const ShareSummary({required this.imageBytes});

  @override
  List<Object?> get props => [imageBytes];
}
