import 'package:equatable/equatable.dart';

abstract class SpeechReadingState extends Equatable {
  dynamic aProps = const [];

  SpeechReadingState([this.aProps]);

  @override
  List<Object?> get props => [...aProps];
}

class SpeechPreparingState extends SpeechReadingState {
  //state when no speech is ready
  SpeechPreparingState() : super();

  @override
  String toString() {
    return this.runtimeType.toString();
  }
}

class SpeechLoadedState extends SpeechReadingState {
  final String speech;

  SpeechLoadedState(this.speech) : super([speech]);

  @override
  String toString() {
    return this.runtimeType.toString();
  }
}

class SpeechPlayingState extends SpeechReadingState {
  SpeechPlayingState() : super();

  @override
  String toString() {
    return this.runtimeType.toString();
  }
}

// class SpeechStopState extends SpeechReadingState {
//   SpeechStopState() : super();
//   @override
//   String toString() {
//     return this.runtimeType.toString();
//   }
// }
