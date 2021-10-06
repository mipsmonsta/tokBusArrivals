import 'package:equatable/equatable.dart';

abstract class StopsHiveState extends Equatable {}



class StopsHiveNotLoadedState extends StopsHiveState {
  final String? error;
  StopsHiveNotLoadedState([this.error]);
  @override
  List<Object?> get props => [error];
}

class StopsHiveLoadedState extends StopsHiveState {
  StopsHiveLoadedState();
  @override
  List<Object?> get props => [];
}
