import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UtilityDialog {
  static void showLoaderDialog(BuildContext context,
      [String message = "Loading..."]) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7), child: Text(message)),
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

    String appName = packageInfo.appName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    showAboutDialog(
        context: context,
        applicationIcon:
            Image.asset('assets/images/ic_launcher.png', width: 60, height: 60),
        applicationName: appName,
        applicationVersion: "$version build: $buildNumber",
        children: [Center(child: Text("© 2021 Thomas Tham "))]);
  }
}