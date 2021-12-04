import 'dart:convert';
import 'dart:io';
import 'package:bus_stops/bus_stops.dart';
import 'package:bus_stops/src/bus_stop_api.dart';
import 'package:dart_console/dart_console.dart';
import 'package:intl/intl.dart';

//run with:
//dart run bin/main.dart
void main() async {
  final console = Console();
  BusStopApiClient apiClient = BusStopApiClient();

  var stops = await apiClient.getBusStops();
  String jsonString = jsonEncode({'List': stops});

  String metaFileJsonString = jsonEncode({
    'Generated': DateTime.now().millisecondsSinceEpoch,
  });

  const fileName = "../../assets/files/bus_stop.json";
  const fileNameMeta = "../../assets/files/bus_stop_meta.json";
  var regExDot = RegExp(r".json");
  var fileNameBak = fileName.split(regExDot)[0] + ".bak";
  var fileNameMetaBak = fileNameMeta.split(regExDot)[0] + ".bak";
  bool needToCompare = false;

  //rename files to old back up files
  if (File(fileName).existsSync()) {
    File(fileName).renameSync(fileNameBak);
    needToCompare = true;
  }
  if (File(fileNameMeta).existsSync()) {
    File(fileNameMeta).renameSync(fileNameMetaBak);
  }

  //get new files
  try {
    await File(fileName).writeAsString(jsonString);
    await File(fileNameMeta).writeAsString(metaFileJsonString);
    stdout.writeln("Success: files $fileName, $fileNameMeta created");
  } catch (e) {
    stdout.writeln('Error when downloading bus stop data: $e');
  }

  if (needToCompare) {
    String oldJson = File(fileNameBak).readAsStringSync();
    Map<String, Stop> oldBusStopsMap = _busStopsMap(oldJson);

    //added bus stops
    Map<String, Stop> newBusStopsMap = _busStopsMap(jsonString);
    List<Stop> newBusStops = List.empty(growable: true);
    for (var key in newBusStopsMap.keys) {
      if (!oldBusStopsMap.containsKey(key)) {
        newBusStops.add(newBusStopsMap[key]!);
      }
    }
    //deleted bus stops
    List<Stop> deletedBusStops = List.empty(growable: true);
    for (var key in oldBusStopsMap.keys) {
      if (!newBusStopsMap.containsKey(key)) {
        deletedBusStops.add(oldBusStopsMap[key]!);
      }
    }

    //stats on number of bus stops
    final numNewBusStops = newBusStopsMap.length;
    final numOldBusStops = oldBusStopsMap.length;
    displayStats(newBusStops, deletedBusStops, numNewBusStops, numOldBusStops,
        console, true);
  }
  exit(0);
}

List<Stop> _loadBusStops(String json) {
  List<dynamic> stopLists = jsonDecode(json)['List'];
  return stopLists.map<Stop>((json) {
    return Stop.fromJson(json);
  }).toList();
}

Map<String, Stop> _busStopsMap(String json) {
  List<Stop> stops = _loadBusStops(json);
  Map<String, Stop> result = {};
  for (Stop stop in stops) {
    result[stop.busStopCode] = stop;
  }
  return result;
}

void displayStats(List<Stop> addedBusStops, List<Stop> removedBusStops,
    int numNewListBusStop, int numOldListBusStop, Console console,
    [bool saveLog = false]) {
  var table1 =
      BusStopsTable(stops: addedBusStops, tblTitle: 'Additional Bus Stops');
  var table2 =
      BusStopsTable(stops: removedBusStops, tblTitle: 'Removed Bus Stops');

  console.clearScreen();
  console.write(table1.render());
  console.setBackgroundColor(ConsoleColor.white);
  console.setForegroundColor(ConsoleColor.black);
  console.writeLine('Number of Bus Stops in Updated List: $numNewListBusStop');
  console.resetColorAttributes();
  console.writeLine();
  console.write(table2.render());
  console.setBackgroundColor(ConsoleColor.white);
  console.setForegroundColor(ConsoleColor.black);
  console.writeLine('Number of Bus Stops in previous List: $numOldListBusStop');
  console.resetColorAttributes();

  if (saveLog) {
    DateTime current = DateTime.now();
    var format = DateFormat.yMd();
    var sink = File('updateLog.log').openSync(mode: FileMode.append);
    try {
      sink.writeStringSync("Update Log on ${format.format(current)}");
      sink.writeStringSync("\n");
      sink.writeStringSync(table1.render());
      sink.writeStringSync("\n");
      sink.writeStringSync(table2.render());
      sink.writeStringSync("\n");
    } catch (e) {
      console.writeLine("Error creating log: $e");
    } finally {
      sink.closeSync();
    }
  }
}

class BusStopsTable extends Table {
  BusStopsTable({required List<Stop> stops, String? tblTitle}) {
    //constructor

    //construct title
    title = tblTitle ?? 'List of Bus Stops';
    List cols = <String>['Code', 'Road Name', 'Description'];

    //construct header row
    for (String element in cols) {
      addColumnDefinition(header: element);
    }

    //construct rows of stop
    for (Stop stop in stops) {
      addRow([stop.busStopCode, stop.roadName, stop.description]);
    }
  }
}
