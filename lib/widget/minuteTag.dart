import 'package:flutter/material.dart';

class MinuteTag extends StatelessWidget {
  final int arrivalMin;
  final String capacity; //SEA, SDA, LSD
  const MinuteTag({Key? key, required this.arrivalMin, required this.capacity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color tagColor = arrivalMin > 5 ? Colors.red : Colors.green;
    var messageToDisplay = "Arr";
    if (arrivalMin > 0) {
      messageToDisplay = arrivalMin.toString().padLeft(2, '0') + " min";
    }

    return Column(children: [
      Container(
          width: 60.0,
          height: 30.0,
          padding: EdgeInsets.all(6),
          child: FittedBox(
              child: Text(messageToDisplay,
                  style: TextStyle(color: Colors.white))),
          decoration: BoxDecoration(
            color: tagColor,
            borderRadius: BorderRadius.circular(12),
          )),
      SizedBox(
        width: 60.0,
        height: 10.0,
        child: Row(
          children: [
            Expanded(
              child: CircleAvatar(
                backgroundColor:
                    capacity == "SEA" ? Colors.green[200] : Colors.transparent,
                maxRadius: 3.0,
              ),
            ),
            Expanded(
              child: CircleAvatar(
                backgroundColor:
                    capacity == "SDA" ? Colors.amber : Colors.transparent,
                maxRadius: 3.0,
              ),
            ),
            Expanded(
              child: CircleAvatar(
                backgroundColor:
                    capacity == "LSD" ? Colors.red : Colors.transparent,
                maxRadius: 3.0,
              ),
            ),
          ],
        ),
      )
    ]);
  }
}
