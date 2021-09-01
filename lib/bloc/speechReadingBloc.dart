import 'package:bloc/bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tokbusarrival/bloc/speechReadingEvent.dart';
import 'package:tokbusarrival/bloc/speechReadingState.dart';

class SpeechReadingBloc extends Bloc<SpeechReadingEvent, SpeechReadingState> {
  final FlutterTts _flutterTts = FlutterTts();
  SpeechReadingBloc() : super(SpeechPreparingState()) {
    setUpTts();
  }

  FlutterTts get getTts {
    return _flutterTts;
  }

  void setUpTts() async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      add(SpeechStopReadingEvent());
    });
  }

  @override
  Stream<SpeechReadingState> mapEventToState(SpeechReadingEvent event) async* {
    switch (event.runtimeType) {
      case SpeechStartLoadingReadingEvent:
        var speech = (event as SpeechStartLoadingReadingEvent).speech;

        if (state is SpeechPlayingState) {
          await _flutterTts.stop();
          yield SpeechPreparingState();
          await Future.delayed(Duration(milliseconds: 500));
          yield SpeechLoadedState(speech);
        } else {
          //i.e. SpeechLoadState or SpeechPreparingState
          yield SpeechLoadedState(speech);
        }
        add(SpeechPlayReadingEvent());
        break;

      case SpeechPlayReadingEvent:
        if (state is SpeechLoadedState) {
          var speech = (state as SpeechLoadedState).speech;
          print("speech: $speech");
          _flutterTts.speak(speech);
          yield SpeechPlayingState();
        }

        break;

      case SpeechStopReadingEvent:
        if (state is SpeechPlayingState) {
          await _flutterTts.stop();
          yield SpeechPreparingState();
        }
        break;
    }
  }
}
