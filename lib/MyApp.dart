import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/material.dart';
import 'package:zone_2_training/settings/SettingsScreen.dart';
import 'package:zone_2_training/settings/preferences.dart';

import 'devices/selection/BluetoothSelectionScreen.dart';
import 'exercise/ExerciseScreen.dart';
import 'devices/BluetoothDevices.dart';
import 'devices/DeviceDataProvider.dart';
import 'devices/SimDevices.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  BluetoothDeviceData? hrmBluetoothDeviceData;
  BluetoothDeviceData? indoorBikeBluetoothDeviceData;

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  Future<void> initBluetooth() async {
    await CentralManager.instance.setUp();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zone 2 Trainer'),
      ),
      body: Column(
        children: [
          _buildCards(context),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: <Widget>[
              OutlinedButton(
                child: const Icon(Icons.settings),
                onPressed: () {
                  _navigateToSettings(context);
                },
              ),
              const Spacer(),
              const Spacer(),
              OutlinedButton(
                  onPressed: isReadyToStartActivity()
                      ? () => _navigateToExercise(context)
                      : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Devices not selected!'))),
                  child: const Text("Start", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }

  bool isReadyToStartActivity() => hrmSelected() && indoorBikeSelected();

  Widget _buildCards(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Card(
            color: hrmBluetoothDeviceData == null ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.secondaryContainer,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () => _navigateAndSelectHRMBluetoothDevice(context),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Heart Rate Device', style: TextStyle(fontWeight: FontWeight.bold)),
                            Builder(builder: (context) {
                              if (hrmBluetoothDeviceData == null) {
                                return const Text("Nothing selected");
                              } else {
                                return Text("Name: ${hrmBluetoothDeviceData?.deviceName}");
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Icon(Icons.monitor_heart),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Card(
            color: indoorBikeBluetoothDeviceData == null
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.secondaryContainer,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () => _navigateAndSelectIndoorBikeBluetoothDevice(context),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Indoor Cycling Device',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Builder(builder: (context) {
                              if (indoorBikeBluetoothDeviceData == null) {
                                return const Text("Nothing selected");
                              } else {
                                return Text("Name: ${indoorBikeBluetoothDeviceData?.deviceName}");
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Icon(Icons.directions_bike),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool hrmSelected() => hrmBluetoothDeviceData != null;

  bool indoorBikeSelected() => indoorBikeBluetoothDeviceData != null;

  Future<void> _navigateAndSelectHRMBluetoothDevice(BuildContext context) async {
    hrmBluetoothDeviceData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BluetoothSelectionScreen()),
    );
    print("Heart rate monitor selected: ${hrmBluetoothDeviceData?.deviceName}");
    setState(() {});
  }

  Future<void> _navigateAndSelectIndoorBikeBluetoothDevice(BuildContext context) async {
    indoorBikeBluetoothDeviceData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BluetoothSelectionScreen()),
    );

    print("Indoor bike selected: ${indoorBikeBluetoothDeviceData?.deviceName}");
    setState(() {});
  }

  Future<void> _navigateToExercise(BuildContext context) async {
    DeviceDataProvider deviceDataProvider;

    if (await Preferences.isSimMode()) {
      deviceDataProvider = SimDevices();
    } else {
      deviceDataProvider = BluetoothDevices(hrmBluetoothDeviceData!.bleScanResult!.deviceId, indoorBikeBluetoothDeviceData!.bleScanResult!.deviceId);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExerciseScreen(deviceDataProvider)),
    );
  }

  Future<void> _navigateToSettings(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}
