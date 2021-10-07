import 'package:flutter/material.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({Key? key}) : super(key: key);

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

List<Widget> _pageChildren = [
  Image.asset('assets/images/feature_hear.png'),
  Image.asset('assets/images/feature_speak.png'),
  Image.asset('assets/images/feature_scan.png'),
  Image.asset('assets/images/feature_find.png')
];

class _TutorialPageState extends State<TutorialPage> {
  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(children: [
          PageView.builder(
            controller: pageController,
            itemBuilder: (context, index) {
              return _pageChildren[index % _pageChildren.length];
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ]),
      ),
    );
  }
}
