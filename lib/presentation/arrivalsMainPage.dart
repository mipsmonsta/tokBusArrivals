import 'package:bus_stops/bus_stops.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:meta_bus_arrivals_api/meta_bus_arrivals_api.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryBloc.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryEvent.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryState.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tokbusarrival/bloc/speechReadingBloc.dart';
import 'package:tokbusarrival/bloc/speechReadingEvent.dart';
import 'package:tokbusarrival/bloc/stopsHiveBloc.dart';
import 'package:tokbusarrival/bloc/stopsHiveEvent.dart';
import 'package:tokbusarrival/bloc/stopsHiveState.dart';
import 'package:tokbusarrival/cubit/bookMarkCubit.dart';
import 'package:tokbusarrival/utility/utility.dart';
import 'package:tokbusarrival/widget/SayDigitsSnackBar.dart';
import 'package:tokbusarrival/widget/bookMarkPageView.dart';
import 'package:tokbusarrival/widget/cannotGetNearbyBusStopSnackBar%20copy.dart';
import 'package:tokbusarrival/widget/locationNASnackBar.dart';
import 'package:tokbusarrival/widget/minuteTag.dart';
import 'package:tokbusarrival/widget/operatorBusTypeColorIcon.dart';
import 'package:tokbusarrival/widget/utilityDialog.dart';
import '../utility/string_extensions.dart';

// add new types for more pop up menu items
enum PopUpMenuTypes { nearestBus, about }

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

class _ArrivalsMainPageState extends State<ArrivalsMainPage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isSpeechListening = false;
  bool _isBusStopDBLoaded = false;
  String _busStopDescription = "";

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en_SG', null);
    _enableSpeech();
    //Prepare Bus Stop Hive
    context.read<StopsHiveBloc>().add(StopsHiveCheckLoadedEvent());
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
      if (busStopDesc != null) {
        _busStopDescription = "$busStopDesc along $busStopRoadName";
      } else
        _busStopDescription = "";
    } else
      _busStopDescription = "";

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
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(LocationNASnackBar());
    } finally {
      Navigator.of(context).pop(); // remove Loader Dialog
    }
  }

  Widget _getPopupMenuButton(BuildContext context) {
    void onSelected(PopUpMenuTypes typeSelected) {
      switch (typeSelected) {
        case PopUpMenuTypes.nearestBus:
          _getNearestBusStopCode(context);
          break;
        case PopUpMenuTypes.about:
          UtilityDialog.showCustomAboutDialog(context);
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
                child: Text('About App'),
                value: PopUpMenuTypes.about,
              )
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
                    ));
                  }
                },
                itemCount: services.length + 1) // +1 for update time item,
            ));
  }

  Widget _getCompoundBusCodeTextField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
              controller: _textEditingController,
              onSubmitted: _onCodeSubmitted,
              keyboardType: TextInputType.number,
              maxLength: 5,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _onCodeSubmitted(_textEditingController.value.text);
                    },
                  ),
                  hintText: "5 digit bus stop code e.g. 65209",
                  label: Text(
                    _busStopDescription,
                    overflow: TextOverflow.ellipsis,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  icon: Icon(Icons.hail))),
        ),
        Container(
            alignment: Alignment.topCenter,
            child: IconButton(
              icon: Icon(Icons.bookmark, color: Colors.grey),
              onPressed: () {
                context.read<BookMarkCubit>().addBookMark(
                    BookMark(_textEditingController.value.text, ""));
              },
            ))
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

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title
          title: Text("Bus Arrivals @ Stop"),
          actions: [
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  context
                      .read<SpeechReadingBloc>()
                      .add(SpeechStopReadingEvent());
                  Navigator.of(context).pushNamed("/settings");
                }),
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
                backgroundColor:
                    _isSpeechListening ? Colors.green.withAlpha(145) : null,
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
                child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                          Colors.lightGreenAccent.withOpacity(0.2),
                          BlendMode.dstATop),
                      image: AssetImage('assets/images/lovebus.png'),
                      fit: BoxFit.cover)),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                _getCompoundBusCodeTextField(context),
                BlocBuilder<BookMarkCubit, List<BookMark>>(
                    builder: (context, state) {
                  if (state.length == 0) return SizedBox.shrink();
                  return BookMarkPageView(
                    width: MediaQuery.of(context).size.width,
                    height: 60.0,
                    bookmarkCodeList: List<String>.generate(
                        state.length, (index) => state[index].busStopCode),
                    onBookMarkPressedCallback: _onBookMarkPressed,
                    onBookMarkLongPressedCallback: _onBooKMarkLongPressed,
                  );
                }),
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
                            child: Text("Error Getting Arrivals: $errorText"));
                        break;

                      case ArrivalsQueryStateSuccess:
                        var services =
                            (state as ArrivalsQueryStateSuccess).services;

                        resultWidget = getListViewBasedOnServices(services);
                        break;
                      case ArrivalsQueryStateEmpty:
                      default:
                        resultWidget = Center(child: Text("No results"));
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
    super.dispose();
  }
}
