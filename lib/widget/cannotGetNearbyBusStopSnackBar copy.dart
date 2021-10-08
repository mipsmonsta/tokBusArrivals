import 'package:flutter/material.dart';

class CannotGetNearbyBusStopSnackBar extends SnackBar {
  final String textContent;
  CannotGetNearbyBusStopSnackBar(
      [this.textContent = "Unable to get nearby bus stops. Try again."])
      : super(
          content: Text(textContent),
        );
}
