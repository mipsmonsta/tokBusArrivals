import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraController _controller;
  bool _controllerInitialized = false;
  String _textToShow = "";

  @override
  void initState() {
    super.initState();
    print(widget.cameras);
    WidgetsBinding.instance?.addObserver(this);
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() => _controllerInitialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]); // only allow portrait mode for screen
    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.camera_alt),
          onPressed: () {

            
            setState(() => _textToShow = "Camera Btn Pressed!");
          },
        ),
        appBar: AppBar(title: Text("Camera Preview")),
        body: LayoutBuilder(builder: (ctx, constraint) {
          //print("$constraint.maxHeight, $constraint.width");

          return (!_controllerInitialized)
              ? Center(
                  child: CircularProgressIndicator(
                  semanticsLabel: "Camera Initializing",
                ))
              : SizedBox(
                  width: constraint.maxWidth,
                  height: constraint.maxHeight,
                  child: Column(children: [
                    AspectRatio(
                        child: CameraPreview(_controller),
                        aspectRatio: 1.0 / _controller.value.aspectRatio),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(_textToShow,
                              style: TextStyle(color: Colors.white))),
                    )
                  ]),
                );
        }));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!_controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
      setState(() => _controllerInitialized = false);
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(_controller.description);
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    await _controller.dispose();
    setState(() => _controllerInitialized = false);

    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        _controllerInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _controller.dispose();
    setState(() {
      _controllerInitialized = false;
    });
    super.dispose();
  }
}
