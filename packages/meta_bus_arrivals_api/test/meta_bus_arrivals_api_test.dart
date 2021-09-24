import 'package:meta_bus_arrivals_api/meta_bus_arrivals_api.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:meta_bus_arrivals_api/key.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

// class FakeMap extends Fake implements Map {}

void main() {
  group('MetaBusArrivalsApiClient', () {
    late http.Client httpClient;
    late MetaBusArrivalsApiClient metaBusArrivalsApiClient;

    setUpAll(() {
      registerFallbackValue<Uri>(FakeUri());
      //registerFallbackValue<Map>(FakeMap());
    });

    setUp(() {
      httpClient = MockHttpClient();
      metaBusArrivalsApiClient =
          MetaBusArrivalsApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(MetaBusArrivalsApiClient(), isNotNull);
      });
    });

    group('Get Bus Arrivals', () {
      const busStopCode = "20251";

      test('apiKey exist', () => expect(apiKey, isNotNull));

      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        try {
          await metaBusArrivalsApiClient
              .getBusArrivals(busStopCode); //api will invoke httpClient.get()
        } catch (_) {}
        verify(() => httpClient.get(
            Uri.http("datamall2.mytransport.sg",
                '/ltaodataservice/BusArrivalv2', {'BusStopCode': busStopCode}),
            headers: {'AccountKey': apiKey})).called(1);
      });

      test('throws BusArrivalsRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any(), headers: any(named: "headers")))
            .thenAnswer((_) async => response);
        expect(
            () async =>
                await metaBusArrivalsApiClient.getBusArrivals(busStopCode),
            throwsA(isA<BusArrivalsRequestFailure>()));
      });

      test('throws BusArrivalsNotFound on empty response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any(), headers: any(named: "headers")))
            .thenAnswer((_) async => response);
        expect(
            () async =>
                await metaBusArrivalsApiClient.getBusArrivals(busStopCode),
            throwsA(isA<BusArrivalsNotFoundFailure>()));
      });

      test('return List<Service> on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''{
    "odata.metadata": "something",
    "BusStopCode": "20251",
    "Services": [{
            "ServiceNo": "176",
            "Operator": "SMRT",
            "NextBus": {
                "OriginCode": "10009",
                "DestinationCode": "45009",
                "EstimatedArrival": "2020-02-12T14:09:11+08:00",
                "Latitude": "1.301219",
                "Longitude": "103.762202",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            },
            "NextBus2": {
                "OriginCode": "10009",
                "DestinationCode": "45009",
                "EstimatedArrival": "2020-02-12T14:21:19+08:00",
                "Latitude": "1.2731256666666666",
                "Longitude": "103.800273",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            },
            "NextBus3": {
                "OriginCode": "10009",
                "DestinationCode": "45009",
                "EstimatedArrival": "2020-02-12T14:44:30+08:00",
                "Latitude": "0",
                "Longitude": "0",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            }
        },
        {
            "ServiceNo": "78",
            "Operator": "TTS",
            "NextBus": {
                "OriginCode": "28009",
                "DestinationCode": "28009",
                "EstimatedArrival": "2020-02-12T14:09:09+08:00",
                "Latitude": "1.3069268333333333",
                "Longitude": "103.73333",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            },
            "NextBus2": {
                "OriginCode": "28009",
                "DestinationCode": "28009",
                "EstimatedArrival": "2020-02-12T14:26:17+08:00",
                "Latitude": "1.3086495",
                "Longitude": "103.76608433333334",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            },
            "NextBus3": {
                "OriginCode": "28009",
                "DestinationCode": "28009",
                "EstimatedArrival": "2020-02-12T14:36:38+08:00",
                "Latitude": "1.3126545",
                "Longitude": "103.7666475",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            }
        }
    ]
}
''');
        when(() => httpClient.get(any(), headers: any(named: "headers")))
            .thenAnswer((_) async => response);
        final actualList =
            await metaBusArrivalsApiClient.getBusArrivals(busStopCode);
        expect(actualList, isA<List<Service>>());
      });

      test(
          'return List<Service> on Empty NextBus2 for Service 176 and Empty NextBus3 for Service 78 response',
          () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''{
    "odata.metadata": "something",
    "BusStopCode": "20251",
    "Services": [{
            "ServiceNo": "176",
            "Operator": "SMRT",
            "NextBus": {
                "OriginCode": "10009",
                "DestinationCode": "45009",
                "EstimatedArrival": "2020-02-12T14:09:11+08:00",
                "Latitude": "1.301219",
                "Longitude": "103.762202",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            },
            "NextBus2": {
                
            },
            "NextBus3": {
                "OriginCode": "10009",
                "DestinationCode": "45009",
                "EstimatedArrival": "2020-02-12T14:44:30+08:00",
                "Latitude": "0",
                "Longitude": "0",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            }
        },
        {
            "ServiceNo": "78",
            "Operator": "TTS",
            "NextBus": {
                "OriginCode": "28009",
                "DestinationCode": "28009",
                "EstimatedArrival": "2020-02-12T14:09:09+08:00",
                "Latitude": "1.3069268333333333",
                "Longitude": "103.73333",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            },
            "NextBus2": {
                "OriginCode": "28009",
                "DestinationCode": "28009",
                "EstimatedArrival": "2020-02-12T14:26:17+08:00",
                "Latitude": "1.3086495",
                "Longitude": "103.76608433333334",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            },
            "NextBus3": {
                "OriginCode": "28009",
                "DestinationCode": "28009",
                "EstimatedArrival": "",
                "Latitude": "1.3126545",
                "Longitude": "103.7666475",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            }
        }
    ]
}
''');
        when(() => httpClient.get(any(), headers: any(named: "headers")))
            .thenAnswer((_) async => response);
        final actualList =
            await metaBusArrivalsApiClient.getBusArrivals(busStopCode);
        expect(
            actualList,
            isA<List<Service>>()
                .having((l) => l[0].bus1 != null, 'bus1', true)
                .having((l) => l[0].bus2 == null, 'bus2', true)
                .having((l) => l[1].bus3 == null, 'bus3', true)
                .having((l) => l[0].busOperator, 'busOperator', 'SMRT')
                .having((l) => l[0].number, 'bus service number', '176')
                .having((l) => l[0].bus1?.type, 'bus type', 'DD'));
      });
    });
  });
}




/*
{
    "odata.metadata": "http://datamall2.mytransport.sg/ltaodataservice/$metadata#BusArrivalv2/@Element",
    "BusStopCode": "20251",
    "Services": [
        {
            "ServiceNo": "176",
            "Operator": "SMRT",
            "NextBus": {
                "OriginCode": "10009",
                "DestinationCode": "45009",
                "EstimatedArrival": "2020-02-12T14:09:11+08:00",
                "Latitude": "1.301219",
                "Longitude": "103.762202",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            },
            "NextBus2": {
                "OriginCode": "10009",
                "DestinationCode": "45009",
                "EstimatedArrival": "2020-02-12T14:21:19+08:00",
                "Latitude": "1.2731256666666666",
                "Longitude": "103.800273",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            },
            "NextBus3": {
                "OriginCode": "10009",
                "DestinationCode": "45009",
                "EstimatedArrival": "2020-02-12T14:44:30+08:00",
                "Latitude": "0",
                "Longitude": "0",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            }
        },
        {
            "ServiceNo": "78",
            "Operator": "TTS",
            "NextBus": {
                "OriginCode": "28009",
                "DestinationCode": "28009",
                "EstimatedArrival": "2020-02-12T14:09:09+08:00",
                "Latitude": "1.3069268333333333",
                "Longitude": "103.73333",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            },
            "NextBus2": {
                "OriginCode": "28009",
                "DestinationCode": "28009",
                "EstimatedArrival": "2020-02-12T14:26:17+08:00",
                "Latitude": "1.3086495",
                "Longitude": "103.76608433333334",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            },
            "NextBus3": {
                "OriginCode": "28009",
                "DestinationCode": "28009",
                "EstimatedArrival": "2020-02-12T14:36:38+08:00",
                "Latitude": "1.3126545",
                "Longitude": "103.7666475",
                "VisitNumber": "1",
                "Load": "SEA",
                "Feature": "WAB",
                "Type": "DD"
            }
        }
    ]
}
*/