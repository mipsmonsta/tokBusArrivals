import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta_bus_arrivals_api/meta_bus_arrivals_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryBloc.dart';
import 'package:tokbusarrival/bloc/speechReadingBloc.dart';
import 'package:tokbusarrival/cubit/SpeechMuteCubit.dart';
import 'package:tokbusarrival/cubit/SpeechPitchCubit.dart';
import 'package:tokbusarrival/cubit/SpeechRateCubit.dart';
import 'package:tokbusarrival/presentation/arrivalsMainPage.dart';
import 'package:tokbusarrival/presentation/speechSettingsPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ArrivalsQueryBloc>(
            create: (context) => ArrivalsQueryBloc(MetaBusArrivalsApiClient())),
        BlocProvider<SpeechReadingBloc>(create: (_) => SpeechReadingBloc()),
        BlocProvider<SpeechMuteCubit>(
            create: (_) =>
                SpeechMuteCubit()), // put above MaterialAppLevel so that mute state read/write app-wide
      ],
      child: MaterialApp(
        title: 'Tok Bus Arrival',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/': (_) => ArrivalsMainPage(),
          '/settings': (_) {
            return MultiBlocProvider(providers: [
              BlocProvider<SpeechPitchCubit>(create: (_) => SpeechPitchCubit()),
              BlocProvider<SpeechRateCubit>(create: (_) => SpeechRateCubit()),
            ], child: const SpeechSettingsPage());
          }
        },
      ),
    );
  }
}
