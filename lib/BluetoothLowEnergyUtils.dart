import 'package:universal_ble/universal_ble.dart';

class BluetoothLowEnergyUtils {

  static String heartRateMeasurementServiceUUID = "180D";
  static String heartrateMeasurementCharacteristicUUID = "2A37";

  static String cyclingPowerMeasurementServiceUUID = "1818";
  static String cyclingPowerMeasurementCharacteristicUUID = "2A63";

  static String fitnessMachineServiceUUID = "1826";
  static String fitnessMachineControlPointCharacteristicUUID = "2AD9";

  static BleCharacteristic? getHeartRateMeasurementCharacteristic(List<BleService> services) {
    return getCharacteristic(services, (service, characteristic) => isHeartRateMeasurementCharacteristic(service, characteristic));
  }

  static bool isHeartRateMeasurementCharacteristic(BleService service, BleCharacteristic characteristic) {
    return service.uuid == heartRateMeasurementServiceUUID &&
        characteristic.uuid == heartrateMeasurementCharacteristicUUID;
  }

  static BleCharacteristic? getCyclingPowerMeasurementCharacteristic(List<BleService> services) {
    return getCharacteristic(services, (service, characteristic) => isCyclingPowerMeasurementCharacteristic(service, characteristic));
  }

  static bool isCyclingPowerMeasurementCharacteristic(BleService service, BleCharacteristic characteristic) {
    return service.uuid == cyclingPowerMeasurementServiceUUID &&
        characteristic.uuid == cyclingPowerMeasurementCharacteristicUUID;
  }

  static BleCharacteristic? getFitnessMachineControlPointCharacteristic(List<BleService> services) {
    return getCharacteristic(services, (service, characteristic) => isFitnessMachineControlPointCharacteristic(service, characteristic));
  }

  static bool isFitnessMachineControlPointCharacteristic(BleService service, BleCharacteristic characteristic) {
    return service.uuid == fitnessMachineServiceUUID &&
        characteristic.uuid == fitnessMachineControlPointCharacteristicUUID;
  }

  static BleCharacteristic? getCharacteristic(List<BleService> services, bool Function(dynamic service, dynamic characteristic) isRequiredPredicate) {
    for (BleService service in services) {
      for (BleCharacteristic characteristic in service.characteristics) {
        if (isRequiredPredicate(service, characteristic)) {
          print("Found characteristic: ${characteristic.uuid}");
          return characteristic;
        }
      }
    }
    throw("Didn't find characteristic");
  }

  static void printServices(List<BleService> services) {
    for (BleService service in services) {
      for (BleCharacteristic characteristic in service.characteristics) {
        print("Service: ${service.uuid}, characteristic: ${characteristic.uuid}");
      }
    }
  }

}
