import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../BluetoothUtils.dart';

class IndoorBikeBluetoothDevice {
  BluetoothDevice bluetoothDevice;

  IndoorBikeBluetoothDevice(this.bluetoothDevice);

  BluetoothCharacteristic? _cyclingPowerMeasurementCharacteristic;
  BluetoothCharacteristic? _fitnessMachineControlPointCharacteristic;

  StreamSubscription<List<int>>? _heartRateListener;

  Future<void> connect() async {
    await bluetoothDevice.connect();
    List<BluetoothService> services = await bluetoothDevice.discoverServices();
    _cyclingPowerMeasurementCharacteristic = BluetoothUtils.getCyclingPowerMeasurementCharacteristic(services)!;
    _fitnessMachineControlPointCharacteristic = BluetoothUtils.getFitnessMachineControlPointCharacteristic(services)!;

    await writeRequestControl();
  }

  Future<void> disconnect() async {
    _heartRateListener?.cancel();
    await bluetoothDevice.disconnect();
  }

  Stream<int> getListener() {
    if (_cyclingPowerMeasurementCharacteristic == null) {
      throw Exception('Not connected to bluetooth device');
    }

    StreamController<int> controller = StreamController<int>();
    _heartRateListener = _cyclingPowerMeasurementCharacteristic!.onValueReceived.listen((value) {
      controller.add(getCurrentActualPower(value));
    });

    _cyclingPowerMeasurementCharacteristic!.setNotifyValue(true);

    return controller.stream;
  }

  Future<void>? writeRequestControl() async {
    return _fitnessMachineControlPointCharacteristic?.write([0]);
  }

  Future<void> setTargetPower(int targetPower) async {
    // TODO: at the moment only one byte of power is sent so it will send a max value of 255
    //List<int> currentPowerSetpointBytes = toUint8List(currentPowerSetpoint);
    await _fitnessMachineControlPointCharacteristic?.write([5, targetPower, 0]);
  }

  int getCurrentActualPower(List<int> value) {
    int powerLSB = value[2];
    int powerMSB = value[3];
    return (powerMSB << 8) + powerLSB;
  }

  List<int> toWriteFormat(int currentPowerSetpoint) {
    Uint8List int16bytes2 = Uint8List(2)..buffer.asInt32List()[0] = currentPowerSetpoint;
    return int16bytes2.toList();
  }
}
