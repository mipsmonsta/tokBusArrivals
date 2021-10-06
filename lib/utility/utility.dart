import 'package:geolocator/geolocator.dart';

class Utility {
  // gps position related
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Denied');
      }
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Permanently_Denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}
