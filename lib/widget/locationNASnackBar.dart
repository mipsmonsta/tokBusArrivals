import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationNASnackBar extends SnackBar {
  String textContent;
  LocationNASnackBar([this.textContent = "Location service permission denied"])
      : super(
            content: Text(textContent),
            action: SnackBarAction(
              label: "Settings",
              onPressed: Geolocator.openLocationSettings,
            ));
}
