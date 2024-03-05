import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zone_2_training/SettingsScreen.dart';

import 'BluetoothSelectionScreen.dart';
import 'ExerciseScreen.dart';

void main() {
  var themeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    ),
  );

  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    [Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan].request().then((status) {
      runApp(MaterialApp(
        theme: themeData,
        home: MyApp(),
      ));
    });
  } else {
    runApp(MaterialApp(
      theme: themeData,
      home: MyApp(),
    ));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  BluetoothDevice? hrmBluetoothDevice;
  BluetoothDevice? indoorBikeBluetoothDevice;

  @override
  void initState() {
    super.initState();
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
                  onPressed: readyToStartActivity()
                      ? () => _navigateToExercise(context)
                      : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Devices not selected!'))),
                  child: const Text("Start", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }

  bool readyToStartActivity() => hrmSelected() && indoorBikeSelected();

  Widget _buildCards(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Card(
            color: hrmBluetoothDevice == null ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.secondaryContainer,
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
                            Text('Heart Rate Device', style: TextStyle(fontWeight: FontWeight.bold)),
                            Builder(builder: (context) {
                              if (hrmBluetoothDevice == null) {
                                return Text("Nothing selected");
                              } else {
                                return Text("Name: ${hrmBluetoothDevice?.platformName}");
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
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
            color:
                indoorBikeBluetoothDevice == null ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.secondaryContainer,
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
                            Text(
                              'Indoor Cycling Device',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Builder(builder: (context) {
                              if (indoorBikeBluetoothDevice == null) {
                                return Text("Nothing selected");
                              } else {
                                return Text("Name: ${indoorBikeBluetoothDevice?.platformName}");
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

  bool hrmSelected() => hrmBluetoothDevice != null;

  bool indoorBikeSelected() => indoorBikeBluetoothDevice != null;

  Future<void> _navigateAndSelectHRMBluetoothDevice(BuildContext context) async {
    hrmBluetoothDevice = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BluetoothSelectionScreen()),
    );
    print("Heart rate monitor selected: ${hrmBluetoothDevice?.platformName}");
    setState(() {});
  }

  Future<void> _navigateAndSelectIndoorBikeBluetoothDevice(BuildContext context) async {
    indoorBikeBluetoothDevice = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BluetoothSelectionScreen()),
    );
    print("Indoor bike selected: ${indoorBikeBluetoothDevice?.platformName}");
    setState(() {});
  }

  Future<void> _navigateToExercise(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExerciseScreen(hrmBluetoothDevice!, indoorBikeBluetoothDevice!)),
    );
  }

  Future<void> _navigateToSettings(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }
}
