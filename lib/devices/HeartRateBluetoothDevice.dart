import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../BluetoothUtils.dart';

class HeartRateBluetoothDevice {
  BluetoothDevice bluetoothDevice;

  HeartRateBluetoothDevice(this.bluetoothDevice);

  BluetoothCharacteristic? _bluetoothCharacteristic;
  StreamSubscription<List<int>>? _heartRateListener;

  Future<void> connect() async {
    await bluetoothDevice.connect();
    List<BluetoothService> services = await bluetoothDevice.discoverServices();
    _bluetoothCharacteristic = BluetoothUtils.getHeartRateMeasurementCharacteristic(services)!;
  }

  Future<void> disconnect() async {
    _heartRateListener?.cancel();
    await bluetoothDevice.disconnect();
  }

  Stream<int> getListener() {
    if (_bluetoothCharacteristic == null) {
      throw Exception('Not connected to bluetooth device');
    }

    StreamController<int> controller = StreamController<int>();
    _heartRateListener = _bluetoothCharacteristic!.onValueReceived.listen((value) {
      controller.add(value[1]);
    });

    _bluetoothCharacteristic!.setNotifyValue(true);

    return controller.stream;
  }
}
