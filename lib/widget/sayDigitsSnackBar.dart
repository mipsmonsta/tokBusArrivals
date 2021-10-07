import 'package:flutter/material.dart';

class SayDigitsSnackBar extends SnackBar {
  final String textContent;
  SayDigitsSnackBar([this.textContent = "Say 5 digits bus stop code"])
      : super(content: Text(textContent));
}
