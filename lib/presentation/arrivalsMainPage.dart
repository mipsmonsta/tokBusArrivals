import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta_bus_arrivals_api/meta_bus_arrivals_api.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryBloc.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryEvent.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryState.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  late final TextEditingController _bsController;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en_SG', null);
    _bsController = TextEditingController();
    _bsController.addListener(_busStopCodeListener);
  }

  void _busStopCodeListener() {
    var bloc = BlocProvider.of<ArrivalsQueryBloc>(context);
    bloc.add(ArrivalsSeekingBusStopCodeEvent(_bsController.text));
  }

  Widget getListViewBasedOnServices(List<Service> services) {
    return Expanded(
      child: ListView.builder(
          itemBuilder: (buildContext, index) {
            Service service = services[index];
            String time1 = service.bus1.estimatedArrival == null
                ? ""
                : DateFormat.Hm().format(
                    service.bus1.estimatedArrival!.add(Duration(hours: 8)));
            String time2 = service.bus1.estimatedArrival == null
                ? ""
                : DateFormat.Hm().format(
                    service.bus2.estimatedArrival!.add(Duration(hours: 8)));
            String time3 = service.bus1.estimatedArrival == null
                ? ""
                : DateFormat.Hm().format(
                    service.bus3.estimatedArrival!.add(Duration(hours: 8)));

            return Center(
                child: ListTile(
                    leading: Icon(Icons.bus_alert),
                    title: Text(service.number),
                    subtitle: Text("Next Buses in: $time1 $time2 $time3")));
          },
          itemCount: services.length),
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
            // the App.build method, and use it to set our appbar title.
            title: Text("Bus Arrivals @ Stop"),
          ),
          body: Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                    controller: _bsController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    decoration: InputDecoration(
                        hintText: "5 digit bus stop code e.g. 65209",
                        icon: Icon(Icons.hail)))),
            BlocBuilder<ArrivalsQueryBloc, ArrivalsQueryState>(
              builder: (context, state) {
                Widget resultWidget;
                switch (state.runtimeType) {
                  case ArrivalsQueryStateLoading:
                    resultWidget = Center(child: CircularProgressIndicator());
                    break;

                  case ArrivalsQueryStateError:
                    var errorText = (state as ArrivalsQueryStateError).error;
                    resultWidget = Center(
                        child: Text("Error Getting Arrivals: $errorText,"));
                    break;

                  case ArrivalsQueryStateSuccess:
                    var services =
                        (state as ArrivalsQueryStateSuccess).services;
                    print(services);
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
          ]))),
    );
  }

  @override
  void dispose() {
    _bsController.dispose();
    super.dispose();
  }
}
