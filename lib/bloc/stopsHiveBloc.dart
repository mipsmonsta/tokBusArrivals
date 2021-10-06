import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bus_stops/bus_stops.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:tokbusarrival/bloc/stopsHiveEvent.dart';
import 'package:tokbusarrival/bloc/stopsHiveState.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kdtree/kdtree.dart';

class StopsHiveBloc extends Bloc<StopsHiveEvent, StopsHiveState> {
  late final box;

  final KDTree _coordinateTree = KDTree([], _distanceFunction, ['lat', 'long']);
  bool _isTreeBuilt = false;

  LazyBox openBusStopBox() {
    return Hive.lazyBox("bus_stops");
  }

  // not public api
  static num _distanceFunction(pointA, pointB) {
    return pow(pointA['lat'] - pointB['lat'], 2) +
        pow(pointA['long'] - pointB['long'], 2);
  }

  void _builtKDTree() async {
    List<Stop> stops =
        await compute<String, List<Stop>>(parseStops, await getJson(false));

    for (Stop stop in stops) {
      _coordinateTree.insert({
        'lat': stop.latitude,
        'long': stop.longitude,
        'code': stop.busStopCode
      });
    }

    _isTreeBuilt = true;
  }

  // find the nearest GPS coordiante based on Geolocator position
  String? nearestBusStopCode(Position position) {
    if (!_isTreeBuilt) _builtKDTree(); //don't rebuilt KDTree unless not built

    var nearestPoints = _coordinateTree
        .nearest({'lat': position.latitude, 'long': position.longitude}, 1);

    if (!nearestPoints.isEmpty) {
      // format would of nearestPoints: [{lat: 1.405351944, long: 103.9018719, code: 65259}, 2.4539925912988856e-7]

      return (nearestPoints[0][0]['code']);
    } //the nearest bus stop code

    return null;
  }

  StopsHiveBloc() : super(StopsHiveNotLoadedState()) {
    box = openBusStopBox();
    on<StopsHiveCheckLoadedEvent>((event, emit) async {
      //both meta_generated and generated are based on timestamp in millisec since epoch (i.e. UTC)
      int meta_generated =
          json.decode(await getJson())['Generated']; //what is stored in json
      int? generated = await box.get("Generated"); // what is stored in hive
      if (generated != null && generated >= meta_generated) {
        emit(StopsHiveLoadedState());
      } else {
        // we must load / re-load hive database
        try {
          await loadBusStops(meta_generated);
          emit(StopsHiveLoadedState());
        } catch (e) {
          emit(StopsHiveNotLoadedState(e.toString()));
        }
      }
    });
  }

  static Future<List<Stop>> parseStops(String jsonString) async {
    List<dynamic> stops = json.decode(jsonString)['List'];
    return stops.map<Stop>((json) => (Stop.fromJson(json))).toList();
  }

  Future<void> loadBusStops(int generated) async {
    await box.clear();

    List<Stop> stops =
        await compute<String, List<Stop>>(parseStops, await getJson(false));
    stops.forEach((stop) async {
      await box.put(stop.busStopCode, stop);
    });
    await box.put('Generated', generated);
  }

  Future<String> getJson([bool meta = true]) async {
    String key = 'assets/files/bus_stop.json';
    if (meta) {
      key = 'assets/files/bus_stop_meta.json';
    }
    return await rootBundle.loadString(key);
  }
}
