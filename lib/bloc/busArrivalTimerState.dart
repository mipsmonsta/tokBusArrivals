import 'package:equatable/equatable.dart';

abstract class BusArrivalTimerState extends Equatable {}

class BusArrivalTimerIdleState extends BusArrivalTimerState {
  BusArrivalTimerIdleState();
  @override
  List<Object?> get props => [];
}

class BusArrivalTimerBusyState extends BusArrivalTimerState {
  final DateTime eta;
  final String busService;
  final String svcOperator;
  final double arrivalRatio;

  BusArrivalTimerBusyState(
      {required this.eta,
      required this.busService,
      required this.svcOperator,
      required this.arrivalRatio});

  @override
  List<Object?> get props => [eta, busService, svcOperator, arrivalRatio];
}

class BusArrivalTimerDoneState extends BusArrivalTimerState {
  final DateTime eta;
  final String busService;
  final String svcOperator;
  BusArrivalTimerDoneState(
      {required this.eta, required this.busService, required this.svcOperator});

  @override
  List<Object?> get props => [eta, busService, svcOperator];
}
