import 'package:equatable/equatable.dart';

abstract class BusArrivalTimerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BusArrivalTimerStartEvent extends BusArrivalTimerEvent {
  final DateTime eta;
  final String busNumber;
  final String svcOperator;

  BusArrivalTimerStartEvent(
      {required this.eta, required this.busNumber, required this.svcOperator});

  @override
  List<Object?> get props => [eta, busNumber, svcOperator];
}

class BusArrivalTimerStopEvent extends BusArrivalTimerEvent {
  BusArrivalTimerStopEvent();
}
