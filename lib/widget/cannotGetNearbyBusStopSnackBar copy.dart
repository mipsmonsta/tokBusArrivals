import 'package:flutter/material.dart';

class CannotGetNearbyBusStopSnackBar extends SnackBar {
  String textContent;
  CannotGetNearbyBusStopSnackBar(
      [this.textContent = "Not about to get nearby bus stops"])
      : super(
          content: Text(textContent),
        );
}
