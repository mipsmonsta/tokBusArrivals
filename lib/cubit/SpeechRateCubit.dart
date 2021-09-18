import 'package:hydrated_bloc/hydrated_bloc.dart';

class SpeechRateCubit extends HydratedCubit<double> {
  final double max = 1.0;
  final double min = 0.25;

  SpeechRateCubit() : super(0.5);

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
