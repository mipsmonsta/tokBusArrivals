import 'package:hydrated_bloc/hydrated_bloc.dart';

class SpeechMuteCubit extends HydratedCubit<bool> {
  SpeechMuteCubit() : super(false); // not mute == false

  void toggleMuteOrUnMute(bool newState) {
    emit(newState);
  }

  @override
  bool? fromJson(Map<String, dynamic> json) {
    return json['value'] as bool;
  }

  @override
  Map<String, dynamic>? toJson(bool state) {
    return {'value': state};
  }
}
