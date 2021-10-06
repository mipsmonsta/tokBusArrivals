import 'dart:async';
import 'dart:convert';
import '../keys.dart';
import 'package:http/http.dart' as http;

import 'models/stop.dart';

class BusStopsRequestFailure implements Exception {}

class BusStopsNotFoundFailure implements Exception {}

class BusStopApiClient {
  final http.Client _httpClient;
  static const _baseUrl = "datamall2.mytransport.sg";

  BusStopApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<List<Stop>> getBusStops() async {
    List<Stop> resultList = <Stop>[];
    List<int> busStopsToken = [
      0,
      500,
      1000,
      1500,
      2000,
      2500,
      3000,
      3500,
      4000,
      4500,
      5000,
      5500
    ];

    for (int token in busStopsToken) {
      var tokenCodeParam = token > 0 ? {"\$skip": token.toString()} : null;
      var stopsRequest =
          Uri.http(_baseUrl, '/ltaodataservice/BusStops', tokenCodeParam);

      var stopsResponse =
          await _httpClient.get(stopsRequest, headers: {'AccountKey': apiKey});

      if (stopsResponse.statusCode != 200) {
        throw BusStopsRequestFailure();
      }

      List<dynamic> stopsJson = jsonDecode(stopsResponse.body)['value'] as List;

      if (stopsJson.isEmpty) {
        break;
      }

      resultList.addAll(List<Stop>.generate(
          stopsJson.length, (index) => Stop.fromJson(stopsJson[index])));
    }
    return resultList;
  }
}
