import 'package:bloc/bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tokbusarrival/bloc/speechReadingEvent.dart';
import 'package:tokbusarrival/bloc/speechReadingState.dart';

class SpeechReadingBloc extends Bloc<SpeechReadingEvent, SpeechReadingState> {
  final FlutterTts _flutterTts = FlutterTts();
  SpeechReadingBloc(bool isMute, double pitch, double rate)
      : super(SpeechPreparingState()) {
    setUpTts(isMute, pitch, rate);
  }

  FlutterTts get getTts {
    return _flutterTts;
  }

  void setUpTts(bool isMute, double pitch, double rate) async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setVolume(isMute ? 0.0 : 1.0);
    await _flutterTts.setPitch(pitch);
    //print("$isMute, $pitch, $rate");
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
