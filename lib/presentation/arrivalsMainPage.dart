import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:tokbusarrival/widget/minuteTag.dart';
import 'package:tokbusarrival/widget/operatorColorIcon.dart';
import '../utility/string_extensions.dart';

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
  String _inputtedCode = "";
  TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en_SG', null);
    _enableSpeech();
  }

  void _enableSpeech() async {
    _speechEnabled =
        await _speechToText.initialize(onStatus: _onSpeechStatusChange);
    if (!mounted) return;
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);

    FlutterBeep.beep();

    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    String potential = result.recognizedWords;
    if (potential.length >= 5) {
      potential = potential.substring(0, 5);
      if (potential.isNumeric()) {
        _textEditingController.value = TextEditingValue(text: potential);
      }
    }
  }

  void _onSpeechStatusChange(String status) {
    if (status == "listening") {
      _isSpeechListening = true;
    } else {
      _isSpeechListening = false;
    }
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
  }

  void _onCodeSubmitted(String code) {
    _inputtedCode = code;
    context
        .read<ArrivalsQueryBloc>()
        .add(ArrivalsSeekingBusStopCodeEvent(code));
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
    _onCodeSubmitted(_inputtedCode);
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
                      leading: OperatorColorIcon(Icons.bus_alert,
                          operatorName: service.busOperator),
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
                    _textEditingController.value = TextEditingValue(text: code);
                  }
                }),
          ],
        ),
        floatingActionButton: _speechEnabled
            ? FloatingActionButton(
                child:
                    Icon(_speechToText.isListening ? Icons.mic : Icons.mic_off),
                onPressed: () {
                  _speechToText.isListening
                      ? _stopListening()
                      : _startListening();
                })
            : null,
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Builder(builder: (context) {
            // bool isSpeechMute = context
            //     .watch<SpeechMuteCubit>()
            //     .state; //Adjust space for materialbanner if speech is muted

            return Padding(
                padding: //isSpeechMute
                    //? const EdgeInsets.fromLTRB(8.0, 52.0, 8.0, 0) :
                    const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
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
                        icon: Icon(Icons.hail))));
          }),
          BlocBuilder<ArrivalsQueryBloc, ArrivalsQueryState>(
            builder: (context, state) {
              Widget resultWidget;
              switch (state.runtimeType) {
                case ArrivalsQueryStateLoading:
                  resultWidget = Center(child: CircularProgressIndicator());
                  break;

                case ArrivalsQueryStateError:
                  var errorText = (state as ArrivalsQueryStateError).error;
                  resultWidget =
                      Center(child: Text("Error Getting Arrivals: $errorText"));
                  break;

                case ArrivalsQueryStateSuccess:
                  var services = (state as ArrivalsQueryStateSuccess).services;
                  var preparedSpeech = _createSpeechFromServices(services);

                  context
                      .read<SpeechReadingBloc>()
                      .add(SpeechStartLoadingReadingEvent(preparedSpeech));
                  //print(services);
                  resultWidget = getListViewBasedOnServices(services);
                  break;
                case ArrivalsQueryStateEmpty:
                default:
                  resultWidget = Center(child: Text("No results"));
                  break;
              }

              return resultWidget;
            },
          )
        ])),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
