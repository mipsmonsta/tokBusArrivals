import 'package:flutter/material.dart';

class BusTimer extends StatelessWidget {
  final double width;
  final double height;
  final String busNumber;
  final String svcOperator;
  final double completion; //0.0 to 1.0
  final DateTime eta;
  final Function onPressedClosed;

  const BusTimer(
      {Key? key,
      required this.onPressedClosed,
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
        child: Stack(alignment: Alignment.center, children: [
          Column(children: [
            const SizedBox(height: 8.0),
            Text("Service $busNumber",
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (completion != 1.0) Text(arrivalETAMsg),
            Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: (completion < 1.0)
                    ? _getbusIndicator(context, completion)
                    : Text(
                        "Look up, bus should be here!",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ))
          ]),
          Positioned(
              right: 0.0,
              top: 0.0,
              child: IconButton(
                  icon: Icon(Icons.close), onPressed: () => onPressedClosed()))
        ]));
  }

  Widget _getbusIndicator(context, value) {
    return Container(
      width: 150,
      height: 32,
      child: Stack(
        children: [
          Stack(
            children: [
              ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [value, value],
                          colors: [Colors.amber, Colors.grey.withAlpha(100)])
                      .createShader(rect);
                },
                child: Container(
                    width: 150,
                    height: 32,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: Image.asset(
                                    "assets/images/bus_timer_indicator.png")
                                .image))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
