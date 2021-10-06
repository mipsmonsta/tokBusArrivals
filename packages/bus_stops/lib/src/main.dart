import 'dart:convert';
import 'dart:io';

import 'package:bus_stops/src/bus_stop_api.dart';

//run with:
//dart run lib/src/main.dart
void main() async {
  BusStopApiClient apiClient = BusStopApiClient();

  var stops = await apiClient.getBusStops();
  String jsonString = jsonEncode({'List': stops});

  String metaFileJsonString = jsonEncode({
    'Generated': DateTime.now().millisecondsSinceEpoch,
  });

  const fileName = "../../assets/files/bus_stop.json";
  const fileNameMeta = "../../assets/files/bus_stop_meta.json";
  await File(fileName).writeAsString(jsonString);
  await File(fileNameMeta).writeAsString(metaFileJsonString);
}
