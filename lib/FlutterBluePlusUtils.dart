import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FlutterBluePlusUtils {
  static const String heartRateMeasurementServiceUUID = "180d";
  static const String heartrateMeasurementCharacteristicUUID = "2a37";

  static const String cyclingPowerMeasurementServiceUUID = "1818";
  static const String cyclingPowerMeasurementCharacteristicUUID = "2a63";

  static const String fitnessMachineServiceUUID ="1826";
  static const String fitnessMachineControlPointCharacteristicUUID ="2ad9";

  static BluetoothCharacteristic? getHeartRateMeasurementCharacteristic(List<BluetoothService> services) {
    return getCharacteristic(services, (characteristic) => FlutterBluePlusUtils.isHeartRateMeasurementCharacteristic(characteristic));
  }

  static bool isHeartRateMeasurementCharacteristic(BluetoothCharacteristic characteristic) {
    return characteristic.serviceUuid.str == heartRateMeasurementServiceUUID &&
        characteristic.characteristicUuid.str == heartrateMeasurementCharacteristicUUID;
  }

  static BluetoothCharacteristic? getCyclingPowerMeasurementCharacteristic(List<BluetoothService> services) {
    return getCharacteristic(services, (characteristic) => FlutterBluePlusUtils.isCyclingPowerMeasurementCharacteristic(characteristic));
  }

  static bool isCyclingPowerMeasurementCharacteristic(characteristic) {
    return characteristic.serviceUuid.str == cyclingPowerMeasurementServiceUUID &&
        characteristic.characteristicUuid.str == cyclingPowerMeasurementCharacteristicUUID;
  }

  static BluetoothCharacteristic? getFitnessMachineControlPointCharacteristic(List<BluetoothService> services) {
    return getCharacteristic(services, (characteristic) => FlutterBluePlusUtils.isFitnessMachineControlPointCharacteristic(characteristic));
  }

  static bool isFitnessMachineControlPointCharacteristic(characteristic) {
    return characteristic.serviceUuid.str == fitnessMachineServiceUUID &&
        characteristic.characteristicUuid.str == fitnessMachineControlPointCharacteristicUUID;
  }

  static BluetoothCharacteristic? getCharacteristic(List<BluetoothService> services, bool Function(dynamic characteristic) isRequiredPredicate) {
    for (BluetoothService bluetoothService in services) {
      for (BluetoothCharacteristic characteristic in bluetoothService.characteristics) {
        if (isRequiredPredicate(characteristic)) {
          print("Found characteristic: $characteristic");
          return characteristic;
        }
      }
    }
    throw("Didn't find characteristic");
  }

}
