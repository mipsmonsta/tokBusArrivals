import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UtilityDialog {
  static void showLoaderDialog(BuildContext context,
      [String message = "Finding Nearby Bus Stop"]) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          SizedBox(
              child: CircularProgressIndicator(), width: 50.0, height: 50.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
          ),
          Expanded(child: Text(message)),
        ],
      ),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void showCustomAboutDialog(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = "SG SayMyBus";
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    showAboutDialog(
        context: context,
        applicationName:
            "", //Workaround for bug where the pakcage name is shown
        children: [
          Center(
              child: Image.asset('assets/images/ic_launcher.png',
                  width: 80, height: 80)),
          Center(child: Text("")),
          Center(child: Text("$appName")),
          Center(child: Text("Version: $version (build: $buildNumber)")),
          Center(child: Text("© 2021 Thomas Tham "))
        ]);
  }
}
