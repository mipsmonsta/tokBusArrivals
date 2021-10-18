import 'package:flutter/material.dart';

class BusTimer extends StatelessWidget {
  final double width;
  final double height;
  final String busNumber;
  final String svcOperator;
  final double completion; //0.0 to 1.0
  final DateTime eta;

  const BusTimer(
      {Key? key,
      required this.width,
      required this.height,
      required this.busNumber,
      required this.svcOperator,
      required this.completion,
      required this.eta})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Duration arrivalInMin = this.eta.difference(DateTime.now());
    String arrivalETAMsg = "ETA ${arrivalInMin.inMinutes} min";
    if (arrivalInMin.inMinutes == 0) arrivalETAMsg = "ETA < 1 min";
    return Container(
        color: (completion == 1.0) ? Colors.red[200] : null,
        width: width,
        height: height,
        child: Column(children: [
          const SizedBox(height: 8.0),
          Text("Service $busNumber",
              style: TextStyle(fontWeight: FontWeight.bold)),
          if (completion != 1.0) Text(arrivalETAMsg),
          Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: (completion < 1.0)
                  ? LinearProgressIndicator(value: completion)
                  : Text(
                      "Look up, bus should be here!",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ))
        ]));
  }
}
