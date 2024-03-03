import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'BluetoothSelectionScreen.dart';
import 'ExerciseScreen.dart';

void main() {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    [Permission.location, Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan].request().then((status) {
      runApp(const MaterialApp(
        home: MyApp(),
      ));
    });
  } else {
    runApp(const MaterialApp(
      home: MyApp(),
    ));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zone 2 Trainer'),
        ),
        body: Column(
          children: [
            _buildButtons(context),
            const Divider(
              color: Colors.blue,
            ),
            Text("Heart Rate Monitor Selected: ${hrmBluetoothDevice?.platformName}"),
            Text("Indoor Bike Selected: ${indoorBikeBluetoothDevice?.platformName}"),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          child: const Text('Pick HRM'),
          onPressed: () => _navigateAndSelectHRMBluetoothDevice(context),
        ),
        ElevatedButton(
          child: const Text('Pick Indoor Bike'),
          onPressed: () => _navigateAndSelectIndoorBikeBluetoothDevice(context),
        ),
        ElevatedButton(
          onPressed: hrmSelected() && indoorBikeSelected() ? () => _navigateToExercise(context) : null,
          child: const Text('Start'),
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
}
