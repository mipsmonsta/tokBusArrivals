import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tokbusarrival/bloc/speechReadingBloc.dart';
import 'package:tokbusarrival/cubit/SpeechPitchCubit.dart';
import 'package:tokbusarrival/cubit/SpeechRateCubit.dart';

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Expanded(
                  child: Column(children: [
                Text("Speech rate"),
                BlocConsumer<SpeechRateCubit, double>(builder: (ctx, state) {
                  return Slider(
                      value: state,
                      divisions: 4,
                      label: state.toString(),
                      onChanged: (value) {
                        ctx.read<SpeechRateCubit>().adjustToValue(value);
                      });
                }, listener: (ctx, state) {
                  ctx.read<SpeechReadingBloc>().getTts.setSpeechRate(state);
                })
              ])),
              Expanded(
                  child: Column(children: [
                Text("Speech Pitch Rate"),
                BlocConsumer<SpeechPitchCubit, double>(builder: (ctx, state) {
                  return Slider(
                      min: 0.5,
                      max: 2.0,
                      divisions: 6,
                      value: state,
                      label: state.toString(),
                      onChanged: (value) {
                        ctx.read<SpeechPitchCubit>().adjustToValue(value);
                      });
                }, listener: (ctx, state) {
                  ctx.read<SpeechReadingBloc>().getTts.setPitch(state);
                }),
                Spacer()
              ])),
            ]));
  }
}
