import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:zone_2_training/preferences.dart';

class BluetoothSelectionScreen extends StatefulWidget {
  const BluetoothSelectionScreen({super.key});

  @override
  _BluetoothSelectionScreenState createState() => _BluetoothSelectionScreenState();
}

class _BluetoothSelectionScreenState extends State<BluetoothSelectionScreen> {
  List<ScanResult> _scanResults = [];
  BluetoothAdapterState _bluetoothAdapterState = BluetoothAdapterState.unknown;
  bool simMode = false;

  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a bluetooth device'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildBluetoothStatusMessage(context),
            _buildSimButton(context),
            _buildListView(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () => scanBluetoothDevices,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    performSimModeTasks();
    startListeningToBluetoothState();
    scanBluetoothDevices();
  }

  Future<void> performSimModeTasks() async {
    simMode = await Preferences.isSimMode();
    setState(() {});
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _adapterStateSubscription.cancel();
    super.dispose();
  }

  void startListeningToBluetoothState() {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((newAdapterState) {
      setState(() {
        _bluetoothAdapterState = newAdapterState;
      });
    });
  }

  void scanBluetoothDevices() {
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      var scanResults = results.where((scanResult) => scanResult.device.platformName.isNotEmpty).toList();
      for (ScanResult r in results) {
        print('Platform name: ${r.device.platformName}, Device ID: ${r.device.remoteId.str}, RSSI: ${r.rssi}');
      }
      if (mounted) {
        setState(() {
          _scanResults = scanResults;
        });
      }
    });
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
  }

  Widget _buildListView() {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (context, index) => ListTile(
          title: Text(_scanResults[index].device.platformName),
          subtitle: Text(_scanResults[index].device.remoteId.str),
          onTap: () {
            Navigator.pop(context, _scanResults[index].device);
          },
        ),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: _scanResults.length,
      ),
    );
  }

  Widget _buildBluetoothStatusMessage(BuildContext context) {
    return Builder(
      builder: (context) {
        if (_bluetoothAdapterState != BluetoothAdapterState.on) {
          return const Text(
            "Bluetooth not on!",
            style: TextStyle(color: Colors.red),
          );
        }
        return const Text("");
      },
    );
  }

  Widget _buildSimButton(BuildContext context) {
    return Builder(
      builder: (context) {
        if (simMode) {
          return OutlinedButton(
              onPressed: () {
                BluetoothDevice bluetoothDevice = BluetoothDevice.fromId("SIM_MODE");
                return Navigator.pop(context, bluetoothDevice);
              },
              child: Text("Use Sim Device"));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
