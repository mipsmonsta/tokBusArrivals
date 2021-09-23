extension NumericStringCheck on String {
  bool isNumeric() {
    if (this == null) {
      return false;
    }
    return int.tryParse(this) != null;
  }
}
