import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'BluetoothUtils.dart';

class HeartRateMonitorDetailPage extends StatefulWidget {
  final String deviceId;

  HeartRateMonitorDetailPage(this.deviceId);

  @override
  State<StatefulWidget> createState() {
    return _HeartRateMonitorDetailPageState();
  }
}

class _HeartRateMonitorDetailPageState extends State<HeartRateMonitorDetailPage> {
  List<BluetoothService> _services = [];
  late BluetoothDevice bluetoothDevice;
  late BluetoothCharacteristic bluetoothCharacteristic;
  int heartRateValue = 0;

  @override
  void initState() {
    bluetoothDevice = BluetoothDevice.fromId(widget.deviceId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PeripheralDetailPage'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            child: const Text('Connect'),
            onPressed: () async {
              await bluetoothDevice.connect();
            },
          ),
          ElevatedButton(
            child: const Text('Find HR Characteristic'),
            onPressed: () async {
              _services = await bluetoothDevice.discoverServices();
              bluetoothCharacteristic = BluetoothUtils.getHeartRateMeasurementCharacteristic(_services)!;
            },
          ),
          ElevatedButton(
            child: const Text('Start Listening for HR changes'),
            onPressed: () async {
              bluetoothCharacteristic.onValueReceived.listen((value) {
                print("New value received $value");
                setState(() {
                  heartRateValue = value[1];
                });
              });
              await bluetoothCharacteristic.setNotifyValue(true);
            },
          ),
          ElevatedButton(
            child: const Text('Disconnect'),
            onPressed: () async {
              await bluetoothDevice.disconnect();
              setState(() {
                heartRateValue = 0;
              });
            },
          ),
          Text('Device UUID: ${widget.deviceId}'),
          Text('HR: $heartRateValue'),
        ],
      ),
    );
  }
}
