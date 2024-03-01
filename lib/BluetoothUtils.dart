import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothUtils {
  static const String heartRateMeasurementServiceUUID = "180d";
  static const String heartrateMeasurementCharacteristicUUID = "2a37";

  static BluetoothCharacteristic? getHeartRateMeasurementCharacteristic(List<BluetoothService> services) {
    for (BluetoothService bluetoothService in services) {
      for (BluetoothCharacteristic characteristic in bluetoothService.characteristics) {
        if (isHeartRateMeasurementCharacteristic(characteristic)) {
          print("Found heart rate characteristic!");
          return characteristic;
        }
      }
    }
    return null;
  }

  static bool isHeartRateMeasurementCharacteristic(BluetoothCharacteristic characteristic) {
    return characteristic.serviceUuid.str == heartRateMeasurementServiceUUID &&
          characteristic.characteristicUuid.str == heartrateMeasurementCharacteristicUUID;
  }
}
