import "package:flutter/material.dart";

class OperatorColorIcon extends StatelessWidget {
  final IconData iconName;
  final String operatorName;
  const OperatorColorIcon(this.iconName, {Key? key, required this.operatorName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? svcColor;
    Color? svcBkgColor;
    switch (operatorName) {
      case "SMRT":
        svcColor = Colors.white;
        svcBkgColor = Colors.red[700];
        break;
      case "GAS":
        svcColor = Colors.red[900];
        svcBkgColor = Colors.amber[800];
        break;
      case "TTS":
        svcColor = Colors.white;
        svcBkgColor = Colors.green[900];
        break;
      case "SBST":
        svcColor = Colors.red[700];
        svcBkgColor = Colors.purple[700];
        break;
    }
    return CircleAvatar(
        backgroundColor: svcBkgColor,
        child: Icon(
          iconName,
          color: svcColor,
          semanticLabel: operatorName,
        ));
  }
}
