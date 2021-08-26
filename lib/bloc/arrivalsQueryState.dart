import 'package:equatable/equatable.dart';
import 'package:meta_bus_arrivals_api/meta_bus_arrivals_api.dart';

abstract class ArrivalsQueryState extends Equatable {}

class ArrivalsQueryStateLoading extends ArrivalsQueryState {
  @override
  String toString() {
    return 'ArrivalsQueryStateLoading';
  }

  @override
  List<Object?> get props => [];
}

class ArrivalsQueryStateSuccess extends ArrivalsQueryState {
  final List<Service> services;
  final String busStopCode;

  ArrivalsQueryStateSuccess(this.services, this.busStopCode);

  @override
  List<Object> get props => [services, busStopCode];

  @override
  String toString() {
    return 'ArrivalsQueryStateSuccess [ Services: ${services.length}, BusStopCode: $busStopCode]';
  }
}

class ArrivalsQueryStateError extends ArrivalsQueryState {
  final String error;

  ArrivalsQueryStateError(this.error);

  @override
  String toString() {
    return 'ArrivalsQueryError [ error: $error]';
  }

  @override
  List<Object?> get props => [error];
}

class ArrivalsQueryStateEmpty extends ArrivalsQueryState {
  ArrivalsQueryStateEmpty();

  @override
  String toString() {
    return 'ArrivalsQueryEmpty';
  }

  @override
  List<Object?> get props => [];
}
