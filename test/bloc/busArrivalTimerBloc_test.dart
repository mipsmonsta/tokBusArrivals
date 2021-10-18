import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerBloc.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerState.dart';

void main() {
  group('BusArrivalTimerBloc', () {
    blocTest<BusArrivalTimerBloc, BusArrivalTimerState>(
      'emits []',
      build: () {
        return BusArrivalTimerBloc();
      },
      expect: () => [],
    );
  });
}
