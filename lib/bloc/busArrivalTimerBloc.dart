import 'package:bloc/bloc.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerEvent.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerState.dart';

class BusArrivalTimerBloc
    extends Bloc<BusArrivalTimerEvent, BusArrivalTimerState> {
  bool _isCancelled = false;
  BusArrivalTimerBloc() : super(BusArrivalTimerIdleState()) {
    on<BusArrivalTimerStartEvent>((event, emit) async {
      if (!(state is BusArrivalTimerIdleState)) return;
      _isCancelled = false;
      Duration initialDifference = event.eta.difference(DateTime.now());
      print("intialDifference: ${initialDifference.inSeconds}");
      // in idle state
      if (initialDifference.isNegative) _isCancelled = true;
      Duration difference = initialDifference;
      do {
        if (_isCancelled) {
          break;
        }
        emit(BusArrivalTimerBusyState(
            eta: event.eta,
            busService: event.busNumber,
            svcOperator: event.svcOperator,
            arrivalRatio:
                1.0 - difference.inSeconds / initialDifference.inSeconds));

        await Future.delayed(Duration(seconds: 10));
        difference = event.eta.difference(DateTime.now());
        print("difference: ${difference.inSeconds}");
        if (difference.isNegative || _isCancelled) {
          break;
        }
      } while (difference.inSeconds > 0);

      if (!_isCancelled) {
        emit(BusArrivalTimerBusyState(
            eta: event.eta,
            busService: event.busNumber,
            svcOperator: event.svcOperator,
            arrivalRatio: 1.0)); // completion
        //not cancelled, then show done state for 30 seconds

        emit(BusArrivalTimerDoneState(
            eta: event.eta,
            busService: event.busNumber,
            svcOperator: event.svcOperator));
        await Future.delayed(Duration(seconds: 30));
      }
      emit(BusArrivalTimerIdleState());
    });

    on<BusArrivalTimerStopEvent>((_, emit) {
      _isCancelled = true;
    });
  }
}
