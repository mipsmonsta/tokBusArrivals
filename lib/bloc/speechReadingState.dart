import 'package:equatable/equatable.dart';

abstract class SpeechReadingState extends Equatable {}

class SpeechPreparingState extends SpeechReadingState {
  //state when no speech is ready
  SpeechPreparingState() : super();

  @override
  String toString() {
    return this.runtimeType.toString();
  }

  @override
  List<Object?> get props => [];
}

class SpeechLoadedState extends SpeechReadingState {
  final String speech;

  SpeechLoadedState(this.speech);

  @override
  String toString() {
    return this.runtimeType.toString();
  }

  @override
  List<Object?> get props => [speech];
}

class SpeechPlayingState extends SpeechReadingState {
  SpeechPlayingState() : super();

  @override
  String toString() {
    return this.runtimeType.toString();
  }

  @override
  List<Object?> get props => [];
}

// class SpeechStopState extends SpeechReadingState {
//   SpeechStopState() : super();
//   @override
//   String toString() {
//     return this.runtimeType.toString();
//   }
// }
