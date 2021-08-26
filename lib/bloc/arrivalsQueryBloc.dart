import 'package:bloc/bloc.dart';

import 'arrivalsQueryEvent.dart';
import 'arrivalsQueryState.dart';
import 'package:meta_bus_arrivals_api/meta_bus_arrivals_api.dart';

class ArrivalsQueryBloc extends Bloc<ArrivalsQueryEvent, ArrivalsQueryState> {
  final MetaBusArrivalsApiClient apiClient;

  ArrivalsQueryBloc(this.apiClient) : super(ArrivalsQueryStateEmpty());

  @override
  Stream<ArrivalsQueryState> mapEventToState(ArrivalsQueryEvent event) async* {
    switch (event.runtimeType) {
      case ArrivalsQueryStartedEvent:
        String busStopCode = (event as ArrivalsQueryStartedEvent).busStopCode;

        yield ArrivalsQueryStateLoading();
        List<Service> services;
        try {
          services = await apiClient.getBusArrivals(busStopCode);
          if (services.isNotEmpty) {
            yield ArrivalsQueryStateSuccess(services, busStopCode);
          } else {
            yield ArrivalsQueryStateEmpty();
          }
        } catch (exception) {
          if (exception is BusArrivalsNotFoundFailure) {
            yield ArrivalsQueryStateEmpty();
          } else {
            yield ArrivalsQueryStateError("Request Failure");
          }
        }

        break;

      case ArrivalsSeekingBusStopCodeEvent:
        var code =
            (event as ArrivalsSeekingBusStopCodeEvent).partialBusStopCode;
        if (code.length == 5) {
          add(ArrivalsQueryStartedEvent(code));
        } else {
          yield ArrivalsQueryStateEmpty();
        }
        break;
    }
  }
}
