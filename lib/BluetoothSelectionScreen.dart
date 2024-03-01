import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothSelectionScreen extends StatefulWidget {
  const BluetoothSelectionScreen({super.key});

  @override
  _BluetoothSelectionScreenState createState() => _BluetoothSelectionScreenState();
}

class _BluetoothSelectionScreenState extends State<BluetoothSelectionScreen> {
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

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
            _buildListView(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      for (ScanResult r in results) {
        print('Platform name: ${r.device.platformName}, Device ID: ${r.device.remoteId.str}, RSSI: ${r.rssi}');
      }
      if (mounted) {
        setState(() {});
      }
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    super.dispose();
  }

  Widget _buildListView() {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (context, index) => ListTile(
          title: Text('${_scanResults[index].device.platformName}(${_scanResults[index].rssi})'),
          subtitle: Text(_scanResults[index].device.remoteId.str),
          onTap: () {
            print("Returning device id: ${_scanResults[index].device.remoteId.str}");
            Navigator.pop(context, _scanResults[index].device.remoteId.str);
          },
        ),
        separatorBuilder: (context, index) => Divider(),
        itemCount: _scanResults.length,
      ),
    );
  }
}
