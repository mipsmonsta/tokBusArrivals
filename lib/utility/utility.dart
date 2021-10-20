import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum LocationPermissionErrors {
  denied,
  permanently_denied,
  permission_finally_obtained,
  no_location_service,
}

class Utility {
  // gps position related
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(LocationPermissionErrors.no_location_service);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(LocationPermissionErrors.denied);
      } else if (permission == LocationPermission.deniedForever) {
        return Future.error(LocationPermissionErrors.permanently_denied);
      } else {
        //while we have permission, this is obtained through a request for permission
        // so let's fail

        return Future.error(
            LocationPermissionErrors.permission_finally_obtained);
      }
    }
    // we have permission at first try, so let's get the position
    return await Geolocator.getCurrentPosition();
  }

  static ThemeData getAppThemeData(BuildContext context) {
    return ThemeData(
        textTheme: Utility
            .getTextTheme(), //GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.lightBlue[100],
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber));
  }

  static TextTheme getTextTheme() {
    TextTheme textTheme = TextTheme(
      headline1: GoogleFonts.montserrat(
          fontSize: 94, fontWeight: FontWeight.w300, letterSpacing: -1.5),
      headline2: GoogleFonts.montserrat(
          fontSize: 61, fontWeight: FontWeight.w300, letterSpacing: -0.5),
      headline3:
          GoogleFonts.montserrat(fontSize: 48, fontWeight: FontWeight.w400),
      headline4: GoogleFonts.montserrat(
          fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      headline5:
          GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w400),
      headline6: GoogleFonts.montserrat(
          fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      subtitle1: GoogleFonts.montserrat(
          fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15),
      subtitle2: GoogleFonts.montserrat(
          fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyText1: GoogleFonts.montserrat(
          fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyText2: GoogleFonts.montserrat(
          fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      button: GoogleFonts.montserrat(
          fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
      caption: GoogleFonts.montserrat(
          fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      overline: GoogleFonts.montserrat(
          fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
    );

    return textTheme;
  }
}
