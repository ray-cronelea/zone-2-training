import 'dart:async';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:universal_ble/universal_ble.dart';

import 'package:zone_2_training/BluetoothLowEnergyUtils.dart';

import '../BluetoothSelectionScreen.dart';
import 'HeartRateDevice.dart';

class BluetoothHeartRateDevice implements HeartRateDevice {
  BluetoothDeviceData bluetoothDeviceData;

  BluetoothHeartRateDevice(this.bluetoothDeviceData);

  BleCharacteristic? _bluetoothCharacteristic;


  StreamController<int> heartRateStreamController = StreamController<int>();
  late final StreamSubscription characteristicNotifiedSubscription;

  @override
  Future<void> connect() async {

    UniversalBle.onConnectionChanged = _handleConnectionChange;
    UniversalBle.onValueChanged = _handleValueChange;


    await UniversalBle.connect(bluetoothDeviceData.bleScanResult!.deviceId);
  }

  void _handleValueChange(String deviceId, String characteristicId, Uint8List value) {
    String s = String.fromCharCodes(value);
    String data = '$s\nraw :  ${value.toString()}';
    print('_handleValueChange $deviceId, $characteristicId, $s');

    if ((equalsIgnoreCase(deviceId,bluetoothDeviceData.bleScanResult?.deviceId)) && (equalsIgnoreCase(characteristicId,BluetoothLowEnergyUtils.heartrateMeasurementCharacteristicUUID))) {
      heartRateStreamController.add(value[1]);
    }

  }

  bool equalsIgnoreCase(String? string1, String? string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  Future<void> _discoverServices(String deviceId) async {
    List<BleService> services = await UniversalBle.discoverServices(deviceId);
    print('${services.length} services discovered for device id $deviceId');
    BluetoothLowEnergyUtils.printServices(services);
  }

  Future<void> _handleConnectionChange(String deviceId, BleConnectionState state) async {
    print('_handleConnectionChange $deviceId, ${state.name}');
    // Auto Discover Services
    if ((state == BleConnectionState.connected)) {
      await _discoverServices(deviceId);

      // Set notifications for required data based on device
        await UniversalBle.setNotifiable(
          bluetoothDeviceData.bleScanResult!.deviceId,
          BluetoothLowEnergyUtils.heartRateMeasurementServiceUUID,
          BluetoothLowEnergyUtils.heartrateMeasurementCharacteristicUUID,
          BleInputProperty.notification,
        );

    }
  }

  @override
  Future<void> disconnect() async {
    UniversalBle.onConnectionChanged = null;
    UniversalBle.onValueChanged = null;

    await UniversalBle.disconnect(bluetoothDeviceData.bleScanResult!.deviceId);
  }

  @override
  Stream<int> getListener() {
    return heartRateStreamController.stream;
  }


}
