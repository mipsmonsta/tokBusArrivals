import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta_bus_arrivals_api/meta_bus_arrivals_api.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryBloc.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryEvent.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryState.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tokbusarrival/bloc/speechReadingBloc.dart';
import 'package:tokbusarrival/bloc/speechReadingEvent.dart';
import 'package:tokbusarrival/cubit/SpeechMuteCubit.dart';
import 'package:tokbusarrival/widget/minuteTag.dart';
import 'package:tokbusarrival/widget/operatorColorIcon.dart';

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
  late ArrivalsQueryBloc _arrivalQueryBloc;
  late SpeechReadingBloc _speechReadingBloc;
  bool _isMaterialBannerVisible = false;
  String _inputtedCode = "";
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en_SG', null);
    _arrivalQueryBloc = context.read<ArrivalsQueryBloc>();
    _speechReadingBloc = context.read<SpeechReadingBloc>();
  }

  void _onCodeSubmitted(String code) {
    _inputtedCode = code;
    _arrivalQueryBloc.add(ArrivalsSeekingBusStopCodeEvent(code));
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

  MaterialBanner getIsMuteMaterialBanner(BuildContext context) {
    return MaterialBanner(
        actions: [
          TextButton(
            child: const Text("UNMUTE"),
            onPressed: () {
              context.read<SpeechMuteCubit>().toggleMuteOrUnMute(false);
              context.read<SpeechReadingBloc>().getTts.setVolume(1.0);
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
          )
        ],
        backgroundColor: Colors.amber,
        content: const Text("Speech Announcement is muted"),
        leading: const Icon(Icons.info));
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
            // the App.build method, and use it to set our appbar title.
            title: Text("Bus Arrivals @ Stop"),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  context
                      .read<SpeechReadingBloc>()
                      .add(SpeechStopReadingEvent());
                  Navigator.of(context).pushNamed("/settings");
                },
              )
            ],
          ),
          body: Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: BlocListener<SpeechMuteCubit, bool>(
                  listener: (ctx, state) {
                    if (state) {
                      ScaffoldMessenger.of(ctx)
                          .showMaterialBanner(getIsMuteMaterialBanner(ctx));
                      setState(() {
                        _isMaterialBannerVisible = true;
                      });
                    } else {
                      setState(() {
                        _isMaterialBannerVisible = false;
                      });
                    }
                  },
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: _isMaterialBannerVisible
                                ? const EdgeInsets.fromLTRB(8.0, 52.0, 8.0, 0)
                                : const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                            child: TextField(
                                onSubmitted: _onCodeSubmitted,
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                decoration: InputDecoration(
                                    hintText:
                                        "5 digit bus stop code e.g. 65209",
                                    icon: Icon(Icons.hail)))),
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
                                        "Error Getting Arrivals: $errorText,"));
                                break;

                              case ArrivalsQueryStateSuccess:
                                var services =
                                    (state as ArrivalsQueryStateSuccess)
                                        .services;
                                var preparedSpeech =
                                    _createSpeechFromServices(services);

                                _speechReadingBloc.add(
                                    SpeechStartLoadingReadingEvent(
                                        preparedSpeech));
                                //print(services);
                                resultWidget =
                                    getListViewBasedOnServices(services);
                                break;
                              case ArrivalsQueryStateEmpty:
                              default:
                                resultWidget =
                                    Center(child: Text("No results"));
                                break;
                            }

                            return resultWidget;
                          },
                        )
                      ])))),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
