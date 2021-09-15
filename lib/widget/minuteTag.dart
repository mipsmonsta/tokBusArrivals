import 'package:flutter/material.dart';

class MinuteTag extends StatelessWidget {
  final int arrivalMin;
  const MinuteTag({Key? key, required this.arrivalMin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color tagColor = arrivalMin > 5 ? Colors.red : Colors.green;
    var messageToDisplay = "Arr";
    if (arrivalMin > 0) {
      messageToDisplay = arrivalMin.toString().padLeft(2, '0') + " min";
    }
    return Container(
        padding: EdgeInsets.all(6),
        height: 30,
        width: 60,
        child: FittedBox(
            child:
                Text(messageToDisplay, style: TextStyle(color: Colors.white))),
        decoration: BoxDecoration(
          color: tagColor,
          borderRadius: BorderRadius.circular(12),
        ));
  }
}
