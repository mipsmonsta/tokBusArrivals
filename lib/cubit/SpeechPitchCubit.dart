import 'package:hydrated_bloc/hydrated_bloc.dart';

class SpeechPitchCubit extends HydratedCubit<double> {
  final double max = 2.0;
  final double min = 0.5;

  SpeechPitchCubit() : super(0.5);

  void adjustToValue(double value) {
    if (value > max) value = max;
    if (value < min) value = min;
    emit(value);
  }

  @override
  double? fromJson(Map<String, dynamic> json) {
    return json['value'] as double;
  }

  @override
  Map<String, dynamic>? toJson(double state) {
    return {'value': state};
  }
}
