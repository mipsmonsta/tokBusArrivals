import 'dart:math';

import 'package:flutter/material.dart';

class EmptyBusStopAnimatedImage extends StatefulWidget {
  static String assetBackgroundPathForType() {
    return "./assets/images/bus_stop.png";
  }

  static String assetForegroundPathForType() {
    return "./assets/images/car.png";
  }

  const EmptyBusStopAnimatedImage({Key? key}) : super(key: key);

  @override
  _EmptyBusStopAnimatedImageState createState() =>
      _EmptyBusStopAnimatedImageState();
}

class _EmptyBusStopAnimatedImageState extends State<EmptyBusStopAnimatedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    const period = 7; //period in seconds for Sine
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: period * 1000))
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var carImageWidth =
        width / 4.0; //set car image width based on screen width on ratio of 1:4
    return Container(
      child: Stack(
        children: [
          Image.asset(EmptyBusStopAnimatedImage.assetBackgroundPathForType()),
          Positioned(
            bottom: -2.0,
            left: -carImageWidth,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (builderContext, child) {
                return Transform.translate(
                    offset: Offset(
                        (width + carImageWidth) * _animationController.value,
                        0.0),
                    child: child);
              },
              child: Image.asset(
                  EmptyBusStopAnimatedImage.assetForegroundPathForType(),
                  width: carImageWidth),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }
}
