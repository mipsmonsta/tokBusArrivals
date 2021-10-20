import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:vibration/vibration.dart';

class VibrationCubit extends HydratedCubit<bool> {
  VibrationCubit() : super(true); // true means allow vibration

  void toggleAllowVibration(bool newState) async {
    bool? canVibrate = await Vibration.hasVibrator();
    if (newState) {
      if (canVibrate != null && canVibrate) {
        emit(newState);
      }
    } else {
      // if new state is false
      emit(newState);
    }
  }

  void startVibration() async {
    if (!state) return;
    bool? canVibrate = await Vibration.hasVibrator();
    if (canVibrate != null && canVibrate) {
      bool? canCustomVibrate = await Vibration.hasCustomVibrationsSupport();
      if (canCustomVibrate != null && canCustomVibrate) {
        Vibration.vibrate(pattern: const [200, 500, 200, 1000]);
      } else {
        Vibration.vibrate();
      }
    }
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
