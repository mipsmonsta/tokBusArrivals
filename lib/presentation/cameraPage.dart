import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

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
  CameraImage? _savedImage;
  double _previousScale = 1.0;
  double _scale = 1.0;
  bool _busPoleVisibility = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addObserver(this);
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _startStreaming();

      setState(() => _controllerInitialized = true);
    });

    Future.delayed(Duration(seconds: 5)).then((_) {
      //hide bus stop pole image after 5 seconds
      setState(() {
        _busPoleVisibility = false;
      });
    });
  }

  void _startStreaming() async {
    await _controller
        .startImageStream((CameraImage image) => _processedCameraImage(image));
  }

  void _processedCameraImage(CameraImage image) {
    setState(() => _savedImage = image);
  }

  void _tryToGetText() async {
    if (_savedImage == null) return;

    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in _savedImage!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(_savedImage!.width.toDouble(), _savedImage!.height.toDouble());

    final InputImageRotation imageRotation =
        InputImageRotationMethods.fromRawValue(
                widget.cameras[0].sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatMethods.fromRawValue(_savedImage?.format.raw) ??
            InputImageFormat.NV21;

    final planeData = _savedImage?.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    final textDetector = GoogleMlKit.vision.textDetector();

    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);

    String text = recognisedText.text;

    textDetector.close();

    if (text.length >= 5) {
      String code = text.substring(0, 5);
      if (!_isNumeric(code)) {
        return;
      }

      setState(() {
        _textToShow = code; //take only first 5 characters
      });
    }
  }

  bool _isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
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
            _tryToGetText();
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
              : GestureDetector(
                  onScaleStart: (_) {
                    _previousScale = _scale;
                  },
                  onScaleUpdate: (scaleUpdateDetails) {
                    _scale = _previousScale * scaleUpdateDetails.scale;
                    _scale > 10.0 ? 10.0 : _scale;
                    _scale < 1.0 ? 1.0 : _scale;
                    _controller.setZoomLevel(_scale);
                  },
                  onScaleEnd: (_) {
                    _previousScale = 1.0;
                  },
                  child: SizedBox(
                    width: constraint.maxWidth,
                    height: constraint.maxHeight,
                    child: Column(children: [
                      AspectRatio(
                          aspectRatio: 1.0 / _controller.value.aspectRatio,
                          child: CameraPreview(_controller,
                              child: Visibility(
                                visible: _busPoleVisibility,
                                child: IgnorePointer(
                                  child: Center(
                                      child: Image(
                                          opacity: AlwaysStoppedAnimation(0.6),
                                          image: AssetImage(
                                              'assets/images/bus_pole_sample.png'))),
                                ),
                              ))),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(_textToShow,
                                style: TextStyle(color: Colors.white))),
                      )
                    ]),
                  ),
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
      _controller.stopImageStream();
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
      ResolutionPreset.high,
    );

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      _startStreaming();
      setState(() {
        _controllerInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _controller.stopImageStream();
    _controller.dispose();
    setState(() {
      _controllerInitialized = false;
    });
    super.dispose();
  }
}
