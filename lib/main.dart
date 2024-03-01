import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'BluetoothSelectionScreen.dart';
import 'ExerciseScreen.dart';
import 'HeartRateMonitorDetailPage.dart';

void main() {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    [Permission.location, Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan].request().then((status) {
      runApp(MaterialApp(
        home: MyApp(),
      ));
    });
  } else {
    runApp(MaterialApp(
      home: MyApp(),
    ));
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? hrmBluetoothRemoteIdStr;
  String? indoorBikeBluetoothRemoteIdStr;

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
            Text("Heart Rate Monitor Selected: $hrmBluetoothRemoteIdStr"),
            Text("Indoor Bike Selected: $indoorBikeBluetoothRemoteIdStr"),
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
          onPressed: hrmSelected() ? () => _navigateHrmDetailPage(context) : null,
          child: const Text('Debug HRM Data'),
        ),
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

  bool hrmSelected() => hrmBluetoothRemoteIdStr != null;

  bool indoorBikeSelected() => indoorBikeBluetoothRemoteIdStr != null;

  Future<dynamic> _navigateHrmDetailPage(BuildContext context) {
    return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HeartRateMonitorDetailPage(hrmBluetoothRemoteIdStr!),
        ));
  }

  Future<void> _navigateAndSelectHRMBluetoothDevice(BuildContext context) async {
    print("Before Heart rate monitor selected: $hrmBluetoothRemoteIdStr");
    hrmBluetoothRemoteIdStr = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BluetoothSelectionScreen()),
    );
    print("Heart rate monitor selected: $hrmBluetoothRemoteIdStr");
    setState(() {});
  }

  Future<void> _navigateAndSelectIndoorBikeBluetoothDevice(BuildContext context) async {
    indoorBikeBluetoothRemoteIdStr = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BluetoothSelectionScreen()),
    );
    print("Indoor bike selected: $indoorBikeBluetoothRemoteIdStr");
    setState(() {});
  }

  Future<void> _navigateToExercise(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExerciseScreen(hrmBluetoothRemoteIdStr!, indoorBikeBluetoothRemoteIdStr!)),
    );
  }
}
