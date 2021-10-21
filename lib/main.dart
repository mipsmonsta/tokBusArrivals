import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta_bus_arrivals_api/meta_bus_arrivals_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tokbusarrival/bloc/arrivalsQueryBloc.dart';
import 'package:tokbusarrival/bloc/busArrivalTimerBloc.dart';
import 'package:tokbusarrival/bloc/speechReadingBloc.dart';
import 'package:tokbusarrival/bloc/stopsHiveBloc.dart';
import 'package:tokbusarrival/cubit/SpeechMuteCubit.dart';
import 'package:tokbusarrival/cubit/SpeechPitchCubit.dart';
import 'package:tokbusarrival/cubit/SpeechRateCubit.dart';
import 'package:tokbusarrival/cubit/bookMarkCubit.dart';
import 'package:tokbusarrival/cubit/vibrationCubit.dart';
import 'package:tokbusarrival/hive/StopsAdapter.dart';
import 'package:tokbusarrival/presentation/arrivalsMainPage.dart';
import 'package:tokbusarrival/presentation/speechSettingsPage.dart';
import 'package:tokbusarrival/presentation/tutorialPage.dart';
import 'package:tokbusarrival/utility/utility.dart';

import 'presentation/cameraPage.dart';
import 'package:path/path.dart' as ppath;

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  var storageDir = await getApplicationDocumentsDirectory();

  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());

  // initialising hive
  var storagePathBoxes = ppath.join(storageDir.path, "boxes");
  await Hive.initFlutter(storagePathBoxes);
  Hive.registerAdapter(StopAdapter());
  await Hive.openLazyBox("bus_stops");

  // font license
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(MyApp(cameras));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final List<CameraDescription> cameras;
  MyApp(this.cameras);

  MaterialBanner getIsMuteMaterialBanner(BuildContext context) {
    return MaterialBanner(
        actions: [
          TextButton(
            child: const Text("UNMUTE"),
            onPressed: () {
              context.read<SpeechMuteCubit>().toggleMuteOrUnMute(false);
            },
          )
        ],
        backgroundColor: Colors.amber,
        content: const Text("Speech Announcement is muted"),
        leading: const Icon(Icons.info));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ArrivalsQueryBloc>(
            create: (context) => ArrivalsQueryBloc(MetaBusArrivalsApiClient())),
        BlocProvider<SpeechPitchCubit>(create: (_) => SpeechPitchCubit()),
        BlocProvider<SpeechRateCubit>(create: (_) => SpeechRateCubit()),
        BlocProvider<SpeechMuteCubit>(create: (_) => SpeechMuteCubit()),
        BlocProvider<SpeechReadingBloc>(
            lazy:
                false, //disable lazy creation so that the tts can be set with vol, pitch and rate to be ready for speech early
            create: (context) => SpeechReadingBloc(
                context
                    .read<SpeechMuteCubit>()
                    .state, // put above MaterialAppLevel so that mute state read/write app-wide
                context.read<SpeechPitchCubit>().state,
                context.read<SpeechRateCubit>().state)),
        BlocProvider<VibrationCubit>(create: (_) => VibrationCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tok Bus Arrival',
        theme: Utility.getAppThemeData(context),
        routes: {
          '/': (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => BookMarkCubit(),
                  ),
                  BlocProvider(
                    create: (_) => StopsHiveBloc(),
                  ),
                  BlocProvider(
                    create: (_) => BusArrivalTimerBloc(),
                  )
                ],
                child: ArrivalsMainPage(),
              ),
          '/settings': (_) => SpeechSettingsPage(),
          '/camera': (_) => CameraPage(cameras: cameras),
          '/tutorial': (_) => TutorialPage(),
        },
      ),
    );
  }
}
