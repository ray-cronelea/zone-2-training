import 'dart:async';
import 'dart:typed_data';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

import 'package:zone_2_training/BluetoothLowEnergyUtils.dart';

import '../BluetoothSelectionScreen.dart';
import 'HeartRateDevice.dart';

class BluetoothHeartRateDevice implements HeartRateDevice {
  BluetoothDeviceData bluetoothDeviceData;

  BluetoothHeartRateDevice(this.bluetoothDeviceData);

  GattCharacteristic? _bluetoothCharacteristic;

  late final StreamSubscription characteristicNotifiedSubscription;

  @override
  Future<void> connect() async {
    await CentralManager.instance.connect(bluetoothDeviceData.peripheral);
    List<GattService> services = await CentralManager.instance.discoverGATT(bluetoothDeviceData.peripheral);
    _bluetoothCharacteristic = BluetoothLowEnergyUtils.getHeartRateMeasurementCharacteristic(services)!;
    CentralManager.instance.setCharacteristicNotifyState(_bluetoothCharacteristic!, state: true);
  }

  @override
  Future<void> disconnect() async {
    _bluetoothCharacteristic = null;
    characteristicNotifiedSubscription.cancel();
    await CentralManager.instance.disconnect(bluetoothDeviceData.peripheral);
  }

  @override
  Stream<int> getListener() {
    if (_bluetoothCharacteristic == null) {
      throw Exception('Not connected to bluetooth device');
    }

    print("Connected to device");
    StreamController<int> controller = StreamController<int>();

    characteristicNotifiedSubscription = CentralManager.instance.characteristicNotified.listen(
      (eventArgs) {
        if (eventArgs.characteristic != _bluetoothCharacteristic) {
          return;
        }
        controller.add(eventArgs.value[1]);
      },
    );

    return controller.stream;
  }

  void printServices(List<GattService> services) {
    for (GattService service in services) {
      for (GattCharacteristic characteristic in service.characteristics) {
        print("Service: ${service.uuid}, characteristic: ${characteristic.uuid}");
      }
    }
  }
}
