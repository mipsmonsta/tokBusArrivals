import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({Key? key}) : super(key: key);

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage>
    with TickerProviderStateMixin {
  PageController pageController = PageController();
  TabController? tabController;
  final double padding = 16.0;
  var _files = [
    [
      'assets/tutorials/captions/feature_hear.txt',
      'assets/tutorials/images/feature_hear.png',
      'assets/tutorials/contents/feature_hear.txt',
    ],
    [
      'assets/tutorials/captions/feature_speak.txt',
      'assets/tutorials/images/feature_speak.png',
      'assets/tutorials/contents/feature_speak.txt',
    ],
    [
      'assets/tutorials/captions/feature_scan.txt',
      'assets/tutorials/images/feature_scan.png',
      'assets/tutorials/contents/feature_scan.txt',
    ],
    [
      'assets/tutorials/captions/feature_find.txt',
      'assets/tutorials/images/feature_find.png',
      'assets/tutorials/contents/feature_find.txt',
    ],
    [
      'assets/tutorials/captions/feature_map.txt',
      'assets/tutorials/images/feature_map.png',
      'assets/tutorials/contents/feature_map.txt',
    ],
    [
      'assets/tutorials/captions/feature_timer.txt',
      'assets/tutorials/images/feature_timer.png',
      'assets/tutorials/contents/feature_timer.txt',
    ],
    [
      'assets/tutorials/captions/feature_bookmark.txt',
      'assets/tutorials/images/feature_bookmark.png',
      'assets/tutorials/contents/feature_bookmark.txt',
    ],
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: _files.length, vsync: this);
    pageController.addListener(_updateTabController);
  }

  void _updateTabController() {
    tabController?.index = pageController.page!.toInt();
    setState(() {});
  }

  @override
  void dispose() {
    pageController.removeListener(_updateTabController);

    super.dispose();
  }

  Widget _createPageWidget(
      String caption, String imagePath, String content, int widgetIndex) {
    return LayoutBuilder(builder: (context, viewportConstraints) {
      // reading to handle scrolling of overflowing content:
      // https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 50.0),
              FutureBuilder<String>(
                future: _getStringFromFilePath(caption),
                builder: (ctx, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                        "${widgetIndex + 1}. " + (snapshot.data ?? "Error"),
                        style: TextStyle(fontWeight: FontWeight.bold));
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Container(
                  child: Image.asset(imagePath),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2.0)),
                ),
              ),
              SizedBox(height: 10.0),
              FutureBuilder<String>(
                  future: _getStringFromFilePath(content),
                  builder: (ctx, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: EdgeInsets.all(padding),
                        child: Text(snapshot.data ?? "Error"),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _pageChildren() {
    return List.generate(
        _files.length,
        (index) => _createPageWidget(
            _files[index][0], _files[index][1], _files[index][2], index));
  }

  Future<String> _getStringFromFilePath(String path) async {
    return await rootBundle.loadString(path);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageChildren = _pageChildren();

    return SafeArea(
      child: Scaffold(
        body: Stack(children: [
          PageView.builder(
            itemCount: pageChildren.length,
            controller: pageController,
            itemBuilder: (context, index) {
              return pageChildren[index];
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Positioned.fill(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TabPageSelector(controller: tabController))),
        ]),
      ),
    );
  }
}
