import 'package:bus_stops/bus_stops.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:meta_bus_arrivals_api/meta_bus_arrivals_api.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryBloc.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryEvent.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryState.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerBloc.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerEvent.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerState.dart';
import 'package:tokbusarrival/bloc/speechReadingBloc.dart';
import 'package:tokbusarrival/bloc/speechReadingEvent.dart';
import 'package:tokbusarrival/bloc/stopsHiveBloc.dart';
import 'package:tokbusarrival/bloc/stopsHiveEvent.dart';
import 'package:tokbusarrival/bloc/stopsHiveState.dart';
import 'package:tokbusarrival/cubit/bookMarkCubit.dart';
import 'package:tokbusarrival/cubit/vibrationCubit.dart';
import 'package:tokbusarrival/presentation/mapMyBusPage.dart';
import 'package:tokbusarrival/utility/constants.dart';
import 'package:tokbusarrival/utility/utility.dart';
import 'package:tokbusarrival/widget/SayDigitsSnackBar.dart';
import 'package:tokbusarrival/widget/bookMarkPageView.dart';
import 'package:tokbusarrival/widget/busTimer.dart';
import 'package:tokbusarrival/widget/cannotGetNearbyBusStopSnackBar%20copy.dart';
import 'package:tokbusarrival/widget/floatingHotAirAnimatedImage.dart';
import 'package:tokbusarrival/widget/locationNASnackBar.dart';
import 'package:tokbusarrival/widget/minuteTag.dart';
import 'package:tokbusarrival/widget/operatorBusTypeColorIcon.dart';
import 'package:tokbusarrival/widget/utilityDialog.dart';
import '../utility/string_extensions.dart';

// add new types for more pop up menu items
enum PopUpMenuTypes { nearestBus, about, tutorial, settings }

class ArrivalsMainPage extends StatefulWidget {
  ArrivalsMainPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  _ArrivalsMainPageState createState() => _ArrivalsMainPageState();
}

class _ArrivalsMainPageState extends State<ArrivalsMainPage>
    with WidgetsBindingObserver {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isSpeechListening = false;
  bool _isBusStopDBLoaded = false;
  List<String> _busStopDescription = [HINTBUSTEXTFIELD];
  MapPageArguments? _busStopMapPageArguments;

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initializeDateFormatting('en_SG', null);
    _enableSpeech();
    //Prepare Bus Stop Hive
    context.read<StopsHiveBloc>().add(StopsHiveCheckLoadedEvent());

    // check whether to show tutorial or in-app rating
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      bool equalCount =
          await Utility.recordAndCheckUseCountEqual(20); //twenty times
      if (!(await Utility.isRated()) && equalCount) {
        final InAppReview inAppReview = InAppReview.instance;
        Utility.setRated();
        inAppReview.requestReview();
      } else {
        // tutorial
        bool isFirstUse = await Utility.isFirstUse();
        if (isFirstUse) {
          UtilityDialog.showTutorialDialog(context);
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      context.read<SpeechReadingBloc>().getTts.stop();
    }
  }

  void _enableSpeech() async {
    _speechEnabled =
        await _speechToText.initialize(onStatus: _onSpeechStatusChange);
    if (!mounted) return;
    setState(() {});
  }

  void _startListening() async {
    //FlutterBeep.beep();
    await _speechToText.listen(
        onResult: _onSpeechResult, listenFor: Duration(seconds: 5));
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    String potential = result.recognizedWords;
    if (potential.length == 5) {
      potential = potential.substring(0, 5);
      if (potential.isNumeric()) {
        //print("Potential is $potential");
        _showOnBusTextFieldAndSearch(potential);
      }
    }
  }

  void _onSpeechStatusChange(String status) {
    var value = false;
    if (status == "listening") {
      value = true;
    }
    setState(() {
      _isSpeechListening = value;
    });

    if (value) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SayDigitsSnackBar());
    } else {
      ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
  }

  void _onCodeSubmitted(String code) async {
    context
        .read<ArrivalsQueryBloc>()
        .add(ArrivalsSeekingBusStopCodeEvent(code));

    if (_isBusStopDBLoaded) {
      Stop? busStop = await context.read<StopsHiveBloc>().box.get(code);
      String? busStopDesc = busStop?.description;
      String? busStopRoadName = busStop?.roadName;
      if (busStop != null) {
        _busStopDescription = ["$busStopDesc", " along $busStopRoadName"];
        _busStopMapPageArguments =
            MapPageArguments(busStop.latitude, busStop.longitude);
      } else {
        _busStopDescription = [HINTBUSTEXTFIELD];
        _busStopMapPageArguments = null;
      }
    } else {
      _busStopDescription = [HINTBUSTEXTFIELD];
      _busStopMapPageArguments = null;
    }

    setState(() {}); //for _busStopDescription
  }

  void _showOnBusTextFieldAndSearch(String numericCode) {
    _textEditingController.value = TextEditingValue(text: numericCode);
    _onCodeSubmitted(numericCode);
  }

  String _createSpeechFromServices(List<Service> services) {
    List<String> svcAnnouncements = List.generate(services.length, (index) {
      if (services[index].bus1 != null) {
        var number = services[index].number;
        var relativeMin = services[index]
            .bus1!
            .estimatedArrival
            .difference(DateTime.now())
            .inMinutes;
        String announcement = "";
        if (relativeMin == 0) {
          announcement = "Service $number has arrived.";
        } else if (relativeMin < 0) {
          int leftMin = -1 * relativeMin;
          announcement = "Service $number has left about $leftMin minute ago.";
        } else {
          announcement =
              "Service $number will arrived in $relativeMin minutes.";
        }

        return announcement;
      }
      return "";
    });

    return svcAnnouncements.join(" ");
  }

  Future<void> _onRefreshActivated() async {
    _onCodeSubmitted(_textEditingController.value.text);
  }

  void _onBookMarkPressed(int index) {
    var busStopCode = context.read<BookMarkCubit>().state[index].busStopCode;
    _showOnBusTextFieldAndSearch(busStopCode);
  }

  void _onBooKMarkLongPressed(int index) async {
    bool? isToDelete = await _showAlertDialog();
    if (isToDelete == true) {
      context.read<BookMarkCubit>().removeBookMark(index);
    }
  }

  void _getNearestBusStopCode(BuildContext context) async {
    Position currPosition;

    try {
      UtilityDialog.showLoaderDialog(context, "Finding nearby bus stop...");
      currPosition = await Utility.determinePosition();
      if (_isBusStopDBLoaded) {
        String? result = // Get Bus Stop Code based on GPS coordinates.
            context.read<StopsHiveBloc>().nearestBusStopCode(currPosition);
        if (result != null) {
          _showOnBusTextFieldAndSearch(result);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(CannotGetNearbyBusStopSnackBar());
        }
      }
    } catch (e) {
      switch (e) {
        case LocationPermissionErrors.permission_finally_obtained:
          // no-op
          break;

        default:
          //location service not available/denied/permanent denied
          ScaffoldMessenger.of(context).showSnackBar(LocationNASnackBar());
          break;
      }
    } finally {
      Navigator.of(context).pop(); // remove Loader Dialog
    }
  }

  Widget _getPopupMenuButton(BuildContext context) {
    void onSelected(PopUpMenuTypes typeSelected) {
      context
          .read<SpeechReadingBloc>()
          .add(SpeechStopReadingEvent()); //stop speech
      switch (typeSelected) {
        case PopUpMenuTypes.nearestBus:
          _getNearestBusStopCode(context);
          break;
        case PopUpMenuTypes.about:
          UtilityDialog.showCustomAboutDialog(context);
          break;
        case PopUpMenuTypes.tutorial:
          Navigator.of(context).pushNamed('/tutorial');
          break;
        case PopUpMenuTypes.settings:
          Navigator.of(context).pushNamed('/settings');
          break;
      }
    }

    return PopupMenuButton<PopUpMenuTypes>(
        onSelected: (PopUpMenuTypes types) => onSelected(types),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<PopUpMenuTypes>>[
              const PopupMenuItem(
                child: Text('Nearby Bus Stop'),
                value: PopUpMenuTypes.nearestBus,
              ),
              const PopupMenuItem(
                child: Text('Tutorial'),
                value: PopUpMenuTypes.tutorial,
              ),
              const PopupMenuItem(
                child: Text('Settings'),
                value: PopUpMenuTypes.settings,
              ),
              const PopupMenuItem(
                child: Text('About App'),
                value: PopUpMenuTypes.about,
              ),
            ]);
  }

  Future<bool?> _showAlertDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bookmark'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Delete Bus Stop bookmark?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _onTapServiceTimer(DateTime eta, String busNumber, String svcOperator) {
    context.read<BusArrivalTimerBloc>().add(BusArrivalTimerStartEvent(
        eta: eta, busNumber: busNumber, svcOperator: svcOperator));
  }

  void _onTimerPressedClose() {
    context.read<BusArrivalTimerBloc>().add(BusArrivalTimerStopEvent());
  }

  Widget getListViewBasedOnServices(List<Service> services) {
    return Expanded(
        child: RefreshIndicator(
            onRefresh: _onRefreshActivated,
            child: ListView.builder(
                itemBuilder: (buildContext, index) {
                  if (index == 0) {
                    //item 0 is the referesh info
                    return Center(
                        child: RichText(
                            text: TextSpan(
                                style: DefaultTextStyle.of(buildContext).style,
                                children: [
                          TextSpan(
                              text: "Updated: ",
                              style: TextStyle(color: Colors.black87)),
                          TextSpan(
                              text: DateFormat.Hm().format(DateTime.now()),
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ])));
                  } else {
                    Service service = services[index - 1];

                    String time1 = service.bus1 == null
                        ? ""
                        : DateFormat.Hm().format(service.bus1!.estimatedArrival
                            .add(Duration(hours: 8)));
                    String time2 = service.bus2 == null
                        ? ""
                        : DateFormat.Hm().format(service.bus2!.estimatedArrival
                            .add(Duration(hours: 8)));
                    String time3 = service.bus3 == null
                        ? ""
                        : DateFormat.Hm().format(service.bus3!.estimatedArrival
                            .add(Duration(hours: 8)));

                    int arrivalMin = service.bus1!.estimatedArrival
                        .difference(DateTime.now())
                        .inMinutes;

                    return Center(
                        child: ListTile(
                      leading: OperatorBusTypeColorIcon(
                        operatorName: service.busOperator,
                        busType: service.bus1?.type ?? "SD",
                      ),
                      title: Text(service.number),
                      subtitle: Text("Next Buses in: $time1 $time2 $time3"),
                      trailing: MinuteTag(
                        arrivalMin: arrivalMin,
                        capacity: service.bus1!.capacity,
                      ),
                      onTap: () => _onTapServiceTimer(
                          service.bus1!.estimatedArrival,
                          service.number,
                          service.busOperator),
                    ));
                  }
                },
                itemCount: services.length + 1) // +1 for update time item,
            ));
  }

  Widget _getCompoundBusCodeTextField(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 8.0,
        ),
        Container(
          margin: EdgeInsets.only(left: 16.0),
          alignment: Alignment.centerLeft,
          child: (_busStopDescription.length == 1)
              ? Text(_busStopDescription[0])
              : RichText(
                  text: TextSpan(
                      text: _busStopDescription[0],
                      style: Theme.of(context).textTheme.bodyText2?.merge(
                          TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue[900],
                              decorationThickness: 2.0)),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushNamed('/map',
                              arguments: _busStopMapPageArguments);
                        },
                      children: [
                        TextSpan(
                            text: _busStopDescription[1],
                            style: Theme.of(context).textTheme.bodyText2)
                      ]),
                ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            const SizedBox(width: 8.0),
            Expanded(
                child: TextField(
                    controller: _textEditingController,
                    onSubmitted: _onCodeSubmitted,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    decoration: InputDecoration(
                      counterText: "", //don't show e.g. 0/5
                      filled: true,
                      fillColor: Colors.lightBlue[100],
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30)),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          _onCodeSubmitted(_textEditingController.value.text);
                        },
                      ),
                      // hintText: "5 digit bus stop code e.g. 65209",
                      // label: Text(
                      //   _busStopDescription,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                    ))),
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 30.0,
              icon: Icon(Icons.bookmark, color: Colors.red),
              onPressed: () {
                if (!_textEditingController.value.text.isEmpty)
                  context.read<BookMarkCubit>().addBookMark(
                      BookMark(_textEditingController.value.text, ""));
              },
            )
          ],
        ),
        const SizedBox(
          height: 8.0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]); // limit to portrait
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset:
              false, //avoid scaffold content resize and overflow at bottom when keyboard is out
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title

            title: Text("Bus Arrivals @ Stop"),
            actions: [
              IconButton(
                  icon: const Icon(Icons.camera),
                  onPressed: () async {
                    // String? code =
                    //     await Navigator.of(context).pushNamed("/camera");
                    var code = await Navigator.of(context).pushNamed("/camera");
                    if (code != null && (code as String).length > 0) {
                      _showOnBusTextFieldAndSearch(code);
                    }
                  }),
              _getPopupMenuButton(context),
            ],
          ),
          floatingActionButton: _speechEnabled
              ? FloatingActionButton(
                  backgroundColor: _isSpeechListening
                      ? Colors.amber
                      : Colors.amber.withAlpha(150),
                  child: Icon(_isSpeechListening ? Icons.mic : Icons.mic_off),
                  onPressed: () async {
                    //stop any speech annoucements so as not to
                    //intefere with the speech recognition
                    context
                        .read<SpeechReadingBloc>()
                        .add(SpeechStopReadingEvent());

                    await Future.delayed(Duration(seconds: 1));
                    _isSpeechListening ? _stopListening() : _startListening();
                  })
              : null,
          body: BlocListener<StopsHiveBloc, StopsHiveState>(
            listener: (ctx, state) {
              if (state is StopsHiveNotLoadedState) {
                _isBusStopDBLoaded = false;
              } else if (state is StopsHiveLoadedState) {
                _isBusStopDBLoaded = true;
              }
            },
            child: BlocListener<ArrivalsQueryBloc, ArrivalsQueryState>(
                listener: (context, state) {
                  if (state is ArrivalsQueryStateSuccess) {
                    var services = state.services;
                    var preparedSpeech = _createSpeechFromServices(services);

                    context
                        .read<SpeechReadingBloc>()
                        .add(SpeechStartLoadingReadingEvent(preparedSpeech));
                  }
                },
                child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Card(
                          margin: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getCompoundBusCodeTextField(context),
                              const SizedBox(height: 8.0),
                            ],
                          ),
                        ),
                        BlocBuilder<BookMarkCubit, List<BookMark>>(
                            builder: (context, state) {
                          if (state.length == 0) return SizedBox.shrink();
                          return Card(
                            color: Colors.amber[200],
                            margin: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 8.0,
                                ),
                                Center(child: Text("Bookmarks")),
                                BookMarkPageView(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60.0,
                                  bookmarkCodeList: List<String>.generate(
                                      state.length,
                                      (index) => state[index].busStopCode),
                                  onBookMarkPressedCallback: _onBookMarkPressed,
                                  onBookMarkLongPressedCallback:
                                      _onBooKMarkLongPressed,
                                ),
                              ],
                            ),
                          );
                        }),
                        BlocConsumer<BusArrivalTimerBloc, BusArrivalTimerState>(
                            builder: (context, state) {
                          late DateTime eta;
                          late String svcOperator;
                          late String busNumber;
                          double completion = 1.0;
                          if (state is BusArrivalTimerIdleState)
                            return SizedBox.shrink();
                          else if (state is BusArrivalTimerDoneState) {
                            eta = state.eta;
                            busNumber = state.busService;
                            svcOperator = state.svcOperator;
                          } else if (state is BusArrivalTimerBusyState) {
                            eta = state.eta;
                            busNumber = state.busService;
                            svcOperator = state.svcOperator;
                            completion = state.arrivalRatio;
                            if (state.isHydrated) {
                              //call event to start timer
                              context.read<BusArrivalTimerBloc>().add(
                                  BusArrivalTimerStartEvent(
                                      eta: state.eta,
                                      busNumber: state.busService,
                                      svcOperator: state.svcOperator));
                            }
                          }

                          return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.all(8.0),
                              child: BusTimer(
                                width: MediaQuery.of(context).size.width,
                                height: 110.0,
                                busNumber: busNumber,
                                svcOperator: svcOperator,
                                eta: eta,
                                completion: completion,
                                onPressedClosed: _onTimerPressedClose,
                              ));
                        }, listener: (context, state) {
                          if (state is BusArrivalTimerDoneState) {
                            context.read<VibrationCubit>().startVibration();
                          }
                        }),
                        const SizedBox(height: 8.0),
                        BlocBuilder<ArrivalsQueryBloc, ArrivalsQueryState>(
                          builder: (context, state) {
                            Widget resultWidget;
                            switch (state.runtimeType) {
                              case ArrivalsQueryStateLoading:
                                resultWidget =
                                    Center(child: CircularProgressIndicator());
                                break;

                              case ArrivalsQueryStateError:
                                var errorText =
                                    (state as ArrivalsQueryStateError).error;
                                resultWidget = Center(
                                    child: Text(
                                        "Error Getting Arrivals: $errorText"));
                                break;

                              case ArrivalsQueryStateSuccess:
                                var services =
                                    (state as ArrivalsQueryStateSuccess)
                                        .services;

                                resultWidget =
                                    getListViewBasedOnServices(services);
                                break;
                              case ArrivalsQueryStateEmpty:
                              default:
                                resultWidget = Expanded(
                                  child: Opacity(
                                    opacity: 0.6,
                                    child: Stack(children: [
                                      Center(
                                          child: FloatingHotAirAnimatedImage()),
                                      Positioned(
                                          top: 8.0,
                                          left: 8.0,
                                          child: Text("Empty like the wind...",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                  ),
                                );

                                break;
                            }

                            return resultWidget;
                          },
                        ),
                      ]),
                )),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    context.read<SpeechReadingBloc>().add(SpeechStopReadingEvent());
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}
