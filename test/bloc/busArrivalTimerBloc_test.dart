import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerBloc.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerState.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  group('BusArrivalTimerBloc', () {
    late Storage storage;
    setUp(() {
      // setting up mock storage
      storage = MockStorage();
      when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
      when<dynamic>(() => storage.read(any())).thenReturn(<String, dynamic>{});
      when(() => storage.delete(any())).thenAnswer((_) async {});
      when(() => storage.clear()).thenAnswer((_) async {});
      HydratedBloc.storage = storage;
    });

    blocTest<BusArrivalTimerBloc, BusArrivalTimerState>(
      'emits [BusArrivalTimerIdleState]',
      build: () {
        return BusArrivalTimerBloc();
      },
      expect: () => [BusArrivalTimerIdleState()],
    );
  });
}
