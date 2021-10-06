import 'package:equatable/equatable.dart';

abstract class StopsHiveEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class StopsHiveCheckLoadedEvent extends StopsHiveEvent {
  StopsHiveCheckLoadedEvent();
}
