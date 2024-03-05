import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zone_2_training/preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _simMode = false;

  @override
  void initState() {
    super.initState();
    readSimMode();
  }

  Future<void> readSimMode() async {
    bool simMode = await Preferences.isSimMode();
    setState(() {
      _simMode = simMode;
    });
  }

  Future<void> writeSimMode(bool value) async {
    await Preferences.saveSimMode(value);
    setState(() {
      _simMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Sim mode"),
            trailing: Switch(
              value: _simMode,
              onChanged: (bool value) {
                print("New value $value");
                writeSimMode(value);
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
