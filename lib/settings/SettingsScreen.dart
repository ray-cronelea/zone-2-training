import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zone_2_training/settings/preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final maxHeartRateController = TextEditingController();

  bool _simMode = false;
  int _maxHeartRate = 0;

  @override
  void initState() {
    super.initState();
    readSettings();
  }

  @override
  void dispose() {
    super.dispose();
    maxHeartRateController.dispose();
  }

  Future<void> readSettings() async {
    bool simMode = await Preferences.isSimMode();
    int maxHeartRate = await Preferences.getMaxHeartRate();
    maxHeartRateController.text = maxHeartRate.toString();
    maxHeartRateController.addListener(() {
      print("change");
      int newVal = int.parse(maxHeartRateController.text);
      if (_maxHeartRate != newVal) {
        _maxHeartRate = newVal;
        saveMaxHeartRate(_maxHeartRate);
      }
    });
    setState(() {
      _simMode = simMode;
      _maxHeartRate = maxHeartRate;
    });
  }

  Future<void> saveSimMode(bool value) async {
    await Preferences.saveSimMode(value);
    setState(() {
      _simMode = value;
    });
  }

  Future<void> saveMaxHeartRate(int value) async {
    await Preferences.saveMaxHeartRate(value);
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
                saveSimMode(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: maxHeartRateController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.monitor_heart),
                suffixText: "BPM",
                labelText: 'Max Heart Rate',
                hintText: 'Enter your max heart rate',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
