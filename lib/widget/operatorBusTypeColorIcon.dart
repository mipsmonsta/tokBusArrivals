import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';

class OperatorBusTypeColorIcon extends StatelessWidget {
  final String operatorName;
  final String busType;
  const OperatorBusTypeColorIcon(
      {Key? key, required this.operatorName, required this.busType})
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
        svcColor = Colors.white;
        svcBkgColor = Colors.purple[700];
        break;
    }
    String assetName = busType == "SD"
        ? "assets/images/singledeck.svg"
        : "assets/images/doubledeck.svg";

    return CircleAvatar(
        backgroundColor: svcBkgColor,
        child: SvgPicture.asset(assetName,
            color: svcColor, width: 60, height: 60));
  }
}
