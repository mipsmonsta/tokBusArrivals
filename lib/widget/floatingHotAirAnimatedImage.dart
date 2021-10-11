import 'dart:math';

import 'package:flutter/material.dart';

class FloatingHotAirAnimatedImage extends StatefulWidget {
  static String assetPathForType() {
    return "./assets/images/nothing_to_see.png";
  }

  const FloatingHotAirAnimatedImage({Key? key}) : super(key: key);

  @override
  _FloatingHotAirAnimatedImageState createState() =>
      _FloatingHotAirAnimatedImageState();
}

class _FloatingHotAirAnimatedImageState
    extends State<FloatingHotAirAnimatedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    const period = 5; //period in seconds for Sine
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: period * 1000))
      ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          AnimatedBuilder(
              animation: _animationController,
              builder: (builderContext, child) {
                return Transform.translate(
                    offset: Offset(5 * cos(2 * pi * _animationController.value),
                        10 * sin(2 * pi * _animationController.value)),
                    child: child);
              },
              child:
                  Image.asset(FloatingHotAirAnimatedImage.assetPathForType())),
          Image.asset('assets/images/nothing_to_see_cloud.png')
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
