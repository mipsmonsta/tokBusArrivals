import "package:flutter/material.dart";

class SpeechSettingsPage extends StatefulWidget {
  const SpeechSettingsPage({Key? key}) : super(key: key);

  @override
  _SpeechSettingsPageState createState() => _SpeechSettingsPageState();
}

class _SpeechSettingsPageState extends State<SpeechSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Speech settings")),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: Column(children: [
                Text("Speech rate"),
                Slider(
                    value: 0.5,
                    onChanged: (value) {
                      print("Speech New Speech Rate: $value");
                    })
              ])),
              Expanded(
                  child: Column(children: [
                Text("Speech Volume"),
                Slider(
                    value: 1.0,
                    onChanged: (value) {
                      print("Speech New Volume Rate: $value");
                    })
              ])),
              Expanded(
                  child: Column(children: [
                Text("Speech Pitch Rate"),
                Slider(
                    min: 0.0,
                    max: 2.0,
                    value: 0.5,
                    onChanged: (value) {
                      print("Speech Pitch Rate: $value");
                    })
              ])),
            ]));
  }
}
