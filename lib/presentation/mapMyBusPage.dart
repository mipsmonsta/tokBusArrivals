import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPageArguments {
  final double lat;
  final double long;

  MapPageArguments(this.lat, this.long);
}

class MapMyBusPage extends StatefulWidget {
  const MapMyBusPage({Key? key}) : super(key: key);

  @override
  _MapMyBusPageState createState() => _MapMyBusPageState();
}

class _MapMyBusPageState extends State<MapMyBusPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as MapPageArguments;

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Map my bus stop"),
            ),
            body: FlutterMap(
                options: MapOptions(
                  center: LatLng(args.lat, args.long),
                  minZoom: 13,
                  maxZoom: 18,
                  zoom: 16,
                  interactiveFlags: InteractiveFlag.pinchZoom,
                ),
                layers: [
                  TileLayerOptions(
                      minZoom: 13,
                      maxZoom: 18,
                      backgroundColor: Colors.black,
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(markers: [
                    Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(args.lat, args.long),
                        builder: (BuildContext context) {
                          return Container(
                              width: 40,
                              height: 40,
                              child: Image(
                                  image: AssetImage(
                                      "assets/images/bus_stop_marker.png")));
                        })
                  ])
                ])));
  }
}
