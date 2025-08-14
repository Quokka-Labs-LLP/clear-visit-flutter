part of 'recording_bloc.dart';

abstract class RecordingEvent extends Equatable {
  const RecordingEvent();

  @override
  List<Object?> get props => [];
}

class RecordingInitialize extends RecordingEvent {
  const RecordingInitialize();
}

class RecordingRequestPermission extends RecordingEvent {
  const RecordingRequestPermission();
}

class RecordingStart extends RecordingEvent {
  const RecordingStart();
}

class RecordingStop extends RecordingEvent {
  const RecordingStop();
}

class RecordingNavigationHandled extends RecordingEvent {
  const RecordingNavigationHandled();
}

class RecordingPauseOrResume extends RecordingEvent {
  const RecordingPauseOrResume();
}

class RecordingTick extends RecordingEvent {
  const RecordingTick();
}


