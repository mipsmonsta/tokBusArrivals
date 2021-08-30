import 'package:equatable/equatable.dart';

abstract class SpeechReadingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SpeechStartLoadingReadingEvent extends SpeechReadingEvent {
  final String speech;
  SpeechStartLoadingReadingEvent(this.speech);

  @override
  List<Object?> get props => [speech];

  @override
  String toString() {
    return this.runtimeType.toString();
  }
}

class SpeechPlayReadingEvent extends SpeechReadingEvent {
  SpeechPlayReadingEvent();

  @override
  String toString() {
    return this.runtimeType.toString();
  }
}

class SpeechStopReadingEvent extends SpeechReadingEvent {
  SpeechStopReadingEvent();

  @override
  String toString() {
    return this.runtimeType.toString();
  }
}
