import 'package:flutter/material.dart';

class CannotGetNearbyBusStopSnackBar extends SnackBar {
  final String textContent;
  CannotGetNearbyBusStopSnackBar(
      [this.textContent = "Not about to get nearby bus stops"])
      : super(
          content: Text(textContent),
        );
}
