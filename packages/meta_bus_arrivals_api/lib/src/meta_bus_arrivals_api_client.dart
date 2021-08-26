import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'models/service.dart';
import '../../key.dart';

class BusArrivalsRequestFailure implements Exception {}

class BusArrivalsNotFoundFailure implements Exception {}

class MetaBusArrivalsApiClient {
  final http.Client _httpClient;
  static const _baseUrl = "datamall2.mytransport.sg";

  MetaBusArrivalsApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<List<Service>> getBusArrivals(String code) async {
    final arrivalsRequest = Uri.http(
        _baseUrl, '/ltaodataservice/BusArrivalv2', {'BusStopCode': code});

    final arrivalsResponse =
        await _httpClient.get(arrivalsRequest, headers: {'AccountKey': apiKey});

    if (arrivalsResponse.statusCode != 200) {
      print(arrivalsResponse.statusCode);
      throw BusArrivalsRequestFailure();
    }

    final arrivalsJson =
        jsonDecode(arrivalsResponse.body) as Map<String, dynamic>;

    if (arrivalsJson.isEmpty) {
      throw BusArrivalsNotFoundFailure();
    }

    final servicesJson = arrivalsJson['Services'] as List;

    return servicesJson
        .map<Service>((entry) => Service.fromJson(entry))
        .toList();
  }
}
