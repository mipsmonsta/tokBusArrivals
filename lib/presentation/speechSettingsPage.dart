import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tokbusarrival/bloc/speechReadingBloc.dart';
import 'package:tokbusarrival/cubit/SpeechMuteCubit.dart';
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
        body: ListView(children: [
          LimitedBox(
            child: Center(child: Text('Adjust Speech Attributes')),
            maxHeight: 100,
          ),
          LimitedBox(
              maxHeight: 100,
              child: Column(children: [
                Text("Speech rate"),
                BlocConsumer<SpeechRateCubit, double>(builder: (ctx, state) {
                  return Slider(
                      min: 0.25,
                      max: 1.0,
                      value: state,
                      divisions: 3,
                      label: state.toString(),
                      onChanged: (value) {
                        ctx.read<SpeechRateCubit>().adjustToValue(value);
                      });
                }, listener: (ctx, state) {
                  ctx.read<SpeechReadingBloc>().getTts.setSpeechRate(state);
                })
              ])),
          LimitedBox(
              maxHeight: 100,
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
              ])),
          LimitedBox(
            maxHeight: 100,
            child: BlocConsumer<SpeechMuteCubit, bool>(
              builder: (ctx, state) {
                return SwitchListTile(
                    title: Text("Mute Speech"),
                    value: state,
                    onChanged: (value) {
                      ctx.read<SpeechMuteCubit>().toggleMuteOrUnMute(value);
                    });
              },
              listener: (ctx, state) {
                double volRate = state ? 0.0 : 1.0;
                ctx.read<SpeechReadingBloc>().getTts.setVolume(volRate);
              },
            ),
          )
        ]));
  }
}
