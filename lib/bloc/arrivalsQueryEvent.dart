import 'package:equatable/equatable.dart';

abstract class ArrivalsQueryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ArrivalsSeekingBusStopCodeEvent extends ArrivalsQueryEvent {
  final String partialBusStopCode;
  ArrivalsSeekingBusStopCodeEvent(this.partialBusStopCode);

  @override
  List<Object?> get props => [partialBusStopCode];

  @override
  String toString() {
    return 'ArrivalsSeekingBusStopCodeEvent';
  }
}

class ArrivalsQueryStartedEvent extends ArrivalsQueryEvent {
  final String busStopCode;
  ArrivalsQueryStartedEvent(this.busStopCode);

  @override
  String toString() {
    return 'ArrivalsQueryStartedEvent';
  }

  @override
  List<Object?> get props => [busStopCode];
}
