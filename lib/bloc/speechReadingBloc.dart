import 'package:bloc/bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tokbusarrival/bloc/speechReadingEvent.dart';
import 'package:tokbusarrival/bloc/speechReadingState.dart';

class SpeechReadingBloc extends Bloc<SpeechReadingEvent, SpeechReadingState> {
  final FlutterTts flutterTts = FlutterTts();
  SpeechReadingBloc() : super(SpeechPreparingState()) {
    setUpTts();
  }

  void setUpTts() async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  @override
  Stream<SpeechReadingState> mapEventToState(SpeechReadingEvent event) async* {
    switch (event.runtimeType) {
      case SpeechStartLoadingReadingEvent:
        var speech = (event as SpeechStartLoadingReadingEvent).speech;

        if (state is SpeechPreparingState) {
          yield SpeechLoadedState(speech);
        } else if (state is SpeechPlayingState) {
          await flutterTts.stop();
          yield SpeechPreparingState();
          await Future.delayed(Duration(milliseconds: 500));
          yield SpeechLoadedState(speech);
          add(SpeechPlayReadingEvent());
        } else {
          yield SpeechLoadedState(speech);
          add(SpeechPlayReadingEvent());
        }
        break;

      case SpeechPlayReadingEvent:
        if (state is SpeechLoadedState) {
          var speech = (state as SpeechLoadedState).speech;
          print("speech: $speech");
          yield SpeechPlayingState();
          await flutterTts.speak(speech);
          yield SpeechPreparingState();
        }

        break;

      case SpeechStopReadingEvent:
        if (state is SpeechPlayingState) {
          await flutterTts.stop();
          yield SpeechPreparingState();
        }
        break;
    }
  }
}
