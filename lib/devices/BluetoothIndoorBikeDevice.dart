import 'dart:async';
import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:zone_2_training/BluetoothLowEnergyUtils.dart';

import '../BluetoothSelectionScreen.dart';
import 'IndoorBikeDevice.dart';

class BluetoothIndoorBikeDevice implements IndoorBikeDevice {
  BluetoothDeviceData bluetoothDeviceData;

  BluetoothIndoorBikeDevice(this.bluetoothDeviceData);

  GattCharacteristic? _cyclingPowerMeasurementCharacteristic;
  GattCharacteristic? _fitnessMachineControlPointCharacteristic;

  late final StreamSubscription characteristicNotifiedSubscription;

  @override
  Future<void> connect() async {
    await CentralManager.instance.connect(bluetoothDeviceData.peripheral);
    List<GattService> services = await CentralManager.instance.discoverGATT(bluetoothDeviceData.peripheral);

    printServices(services);

    _cyclingPowerMeasurementCharacteristic = BluetoothLowEnergyUtils.getCyclingPowerMeasurementCharacteristic(services)!;
    _fitnessMachineControlPointCharacteristic = BluetoothLowEnergyUtils.getFitnessMachineControlPointCharacteristic(services)!;

    await CentralManager.instance.setCharacteristicNotifyState(_cyclingPowerMeasurementCharacteristic!, state: true);

    await writeRequestControl();
  }

  void printServices(List<GattService> services) {
    for (GattService service in services) {
      for (GattCharacteristic characteristic in service.characteristics) {
        print("Service: ${service.uuid}, characteristic: ${characteristic.uuid}");
      }
    }
  }

  @override
  Future<void> disconnect() async {
    _cyclingPowerMeasurementCharacteristic = null;
    _fitnessMachineControlPointCharacteristic = null;
    await CentralManager.instance.disconnect(bluetoothDeviceData.peripheral);
  }

  @override
  Stream<int> getListener() {
    if (_cyclingPowerMeasurementCharacteristic == null) {
      throw Exception('Not connected to bluetooth device');
    }

    StreamController<int> controller = StreamController<int>();

    characteristicNotifiedSubscription = CentralManager.instance.characteristicNotified.listen(
      (eventArgs) {
        if (eventArgs.characteristic != _cyclingPowerMeasurementCharacteristic) {
          return;
        }
        controller.add(getCurrentActualPower(eventArgs.value));
      },
    );

    return controller.stream;
  }

  Future<void> writeRequestControl() async {
    print("Indoor bike requesting control");
    return CentralManager.instance.writeCharacteristic(
      _fitnessMachineControlPointCharacteristic!,
      value: Uint8List.fromList([0]),
      type: GattCharacteristicWriteType.withResponse,
    );
  }

  @override
  Future<void> setTargetPower(int targetPower) async {
    // TODO: at the moment only one byte of power is sent so it will send a max value of 255
    //List<int> currentPowerSetpointBytes = toUint8List(currentPowerSetpoint);

    return CentralManager.instance.writeCharacteristic(
      _fitnessMachineControlPointCharacteristic!,
      value: Uint8List.fromList([5, targetPower, 0]),
      type: GattCharacteristicWriteType.withResponse,
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
