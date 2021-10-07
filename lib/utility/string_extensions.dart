extension NumericStringCheck on String {
  bool isNumeric() {
    return int.tryParse(this) != null;
  }
}
