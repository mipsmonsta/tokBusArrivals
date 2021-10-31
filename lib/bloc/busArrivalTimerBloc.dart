import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerEvent.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerState.dart';

class BusArrivalTimerBloc
    extends HydratedBloc<BusArrivalTimerEvent, BusArrivalTimerState> {
  bool _isCancelled = false;
  BusArrivalTimerBloc() : super(BusArrivalTimerIdleState()) {
    on<BusArrivalTimerStartEvent>((event, emit) async {
      if (!(state is BusArrivalTimerIdleState ||
          state is BusArrivalTimerBusyState)) return;
      _isCancelled = false;
      Duration initialDifference = event.eta.difference(DateTime.now());
      //print("intialDifference: ${initialDifference.inSeconds}");
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

        await Future.delayed(Duration(seconds: 2));
        difference = event.eta.difference(DateTime.now());
        //print("difference: ${difference.inSeconds}");
        if (difference.isNegative || _isCancelled) {
          emit(BusArrivalTimerIdleState());
          return;
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
        await Future.delayed(Duration(seconds: 10)); //show for 10 seconds
      }
      emit(BusArrivalTimerIdleState());
    });

    on<BusArrivalTimerStopEvent>((_, emit) {
      emit(BusArrivalTimerIdleState());
      _isCancelled = true;
    });
  }

  @override
  BusArrivalTimerState? fromJson(Map<String, dynamic> json) {
    BusArrivalTimerState resultState;
    if (json["type"] == "busy") {
      DateTime eta = DateTime.fromMillisecondsSinceEpoch(json["eta"]);
      String busService = json["busService"];
      String svcOperator = json["busOperator"];
      double arrivalRatio = json["arrivalRatio"];
      //
      resultState = BusArrivalTimerBusyState(
          eta: eta,
          busService: busService,
          svcOperator: svcOperator,
          arrivalRatio: arrivalRatio,
          isHydrated: true);
    } else {
      resultState = BusArrivalTimerIdleState();
    }
    return resultState;
  }

  @override
  Map<String, dynamic>? toJson(BusArrivalTimerState state) {
    if (state is BusArrivalTimerBusyState) {
      return {
        "type": "busy",
        "busService": state.busService,
        "busOperator": state.svcOperator,
        "eta": state.eta.millisecondsSinceEpoch,
        "arrivalRatio": state.arrivalRatio,
      };
    } else if (state is BusArrivalTimerIdleState) {
      // saving idle state allow hydration; bug fix
      // bugfix: prevent canceled timer to be resurrected on app restart
      return {"type": "idle"};
    }
    return null;
  }
}
