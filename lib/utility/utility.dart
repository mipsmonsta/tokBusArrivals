import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

enum LocationPermissionErrors {
  denied,
  permanently_denied,
  permission_finally_obtained,
  no_location_service,
}

class Utility {
  // gps position related
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(LocationPermissionErrors.no_location_service);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(LocationPermissionErrors.denied);
      } else if (permission == LocationPermission.deniedForever) {
        return Future.error(LocationPermissionErrors.permanently_denied);
      } else {
        //while we have permission, this is obtained through a request for permission
        // so let's fail

        return Future.error(
            LocationPermissionErrors.permission_finally_obtained);
      }
    }
    // we have permission at first try, so let's get the position
    return await Geolocator.getCurrentPosition();
  }

  static ThemeData getAppThemeData() {
    return ThemeData(
        scaffoldBackgroundColor: Colors.lightBlue[100],
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber));
  }
}
