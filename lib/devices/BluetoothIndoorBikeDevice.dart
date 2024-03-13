import 'dart:async';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:universal_ble/universal_ble.dart';

import '../BluetoothLowEnergyUtils.dart';
import '../BluetoothSelectionScreen.dart';
import 'IndoorBikeDevice.dart';

class BluetoothIndoorBikeDevice implements IndoorBikeDevice {
  BluetoothDeviceData bluetoothDeviceData;

  BluetoothIndoorBikeDevice(this.bluetoothDeviceData);

  BleCharacteristic? _cyclingPowerMeasurementCharacteristic;
  BleCharacteristic? _fitnessMachineControlPointCharacteristic;

  late final StreamSubscription characteristicNotifiedSubscription;

  StreamController<int> controller = StreamController<int>();

  @override
  Future<void> connect() async {
    UniversalBle.onConnectionChanged = _handleConnectionChange;
    UniversalBle.onValueChanged = _handleValueChange;

    await UniversalBle.connect(bluetoothDeviceData.bleScanResult!.deviceId);

    // List<BleService> services = await UniversalBle.discoverServices(bluetoothDeviceData.bleScanResult!.deviceId);
    // BluetoothLowEnergyUtils.printServices(services);

    // _cyclingPowerMeasurementCharacteristic = BluetoothLowEnergyUtils.getCyclingPowerMeasurementCharacteristic(services)!;
    // _fitnessMachineControlPointCharacteristic = BluetoothLowEnergyUtils.getFitnessMachineControlPointCharacteristic(services)!;

    // await UniversalBle.setNotifiable(
    //   bluetoothDeviceData.bleScanResult!.deviceId,
    //   BluetoothLowEnergyUtils.cyclingPowerMeasurementServiceUUID,
    //   "2a63",
    //   BleInputProperty.notification,
    // );

  }

  Future<void> _handleConnectionChange(String deviceId, BleConnectionState state) async {
    print('_handleConnectionChange $deviceId, ${state.name}');
    // Auto Discover Services
    if ((state == BleConnectionState.connected)) {
      await _discoverServices(deviceId);

      // Set notifications for required data based on device
      if (deviceId == bluetoothDeviceData.bleScanResult!.deviceId) {
        await UniversalBle.setNotifiable(
          bluetoothDeviceData.bleScanResult!.deviceId,
          BluetoothLowEnergyUtils.cyclingPowerMeasurementServiceUUID,
          BluetoothLowEnergyUtils.cyclingPowerMeasurementCharacteristicUUID,
          BleInputProperty.notification,
        );
      }
    }
  }

  void _handleValueChange(String deviceId, String characteristicId, Uint8List value) {
    String s = String.fromCharCodes(value);
    print('_handleValueChange $deviceId, $characteristicId, $s');

    if (equalsIgnoreCase(deviceId,bluetoothDeviceData.bleScanResult!.deviceId) && equalsIgnoreCase(characteristicId, BluetoothLowEnergyUtils.cyclingPowerMeasurementCharacteristicUUID)) {
      controller.add(_getCurrentActualPower(value));
    }
  }

  int _getCurrentActualPower(List<int> value) {
    int powerLSB = value[2];
    int powerMSB = value[3];
    return (powerMSB << 8) + powerLSB;
  }

  bool equalsIgnoreCase(String? string1, String? string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  Future<void> _discoverServices(String deviceId) async {
    List<BleService> services = await UniversalBle.discoverServices(deviceId);
    print('${services.length} services discovered for device id $deviceId');
    BluetoothLowEnergyUtils.printServices(services);
  }

  @override
  Future<void> disconnect() async {
    _cyclingPowerMeasurementCharacteristic = null;
    _fitnessMachineControlPointCharacteristic = null;
    UniversalBle.setNotifiable(
      bluetoothDeviceData.bleScanResult!.deviceId,
      BluetoothLowEnergyUtils.cyclingPowerMeasurementServiceUUID,
      "2a63",
      BleInputProperty.notification,
    );
  }

  @override
  Stream<int> getListener() {
    return controller.stream;
  }

  @override
  Future<void> setTargetPower(int targetPower) async {
    print("Indoor bike requesting control");
    UniversalBle.writeValue(
      bluetoothDeviceData.bleScanResult!.deviceId,
      BluetoothLowEnergyUtils.fitnessMachineServiceUUID,
      "2a63",
      Uint8List.fromList([0]),
      BleOutputProperty.withResponse,
    );

    // TODO: at the moment only one byte of power is sent so it will send a max value of 255
    //List<int> currentPowerSetpointBytes = toUint8List(currentPowerSetpoint);

    return UniversalBle.writeValue(
      bluetoothDeviceData.bleScanResult!.deviceId,
      BluetoothLowEnergyUtils.fitnessMachineServiceUUID,
      "2a63",
      Uint8List.fromList([5, targetPower, 0]),
      BleOutputProperty.withResponse,
    );
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
