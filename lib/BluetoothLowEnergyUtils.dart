import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

class BluetoothLowEnergyUtils {

  static UUID exampleUUID = UUID.short(0x180f);

  static UUID heartRateMeasurementServiceUUID = UUID.short(0x180d);
  static UUID heartrateMeasurementCharacteristicUUID = UUID.short(0x2a37);

  static UUID cyclingPowerMeasurementServiceUUID = UUID.short(0x1818);
  static UUID cyclingPowerMeasurementCharacteristicUUID = UUID.short(0x2a63);

  static UUID fitnessMachineServiceUUID = UUID.short(0x1826);
  static UUID fitnessMachineControlPointCharacteristicUUID = UUID.short(0x2ad9);

  static GattCharacteristic? getHeartRateMeasurementCharacteristic(List<GattService> services) {
    return getCharacteristic(services, (service, characteristic) => isHeartRateMeasurementCharacteristic(service, characteristic));
  }

  static bool isHeartRateMeasurementCharacteristic(GattService service, GattCharacteristic characteristic) {
    return service.uuid == heartRateMeasurementServiceUUID &&
        characteristic.uuid == heartrateMeasurementCharacteristicUUID;
  }

  static GattCharacteristic? getCyclingPowerMeasurementCharacteristic(List<GattService> services) {
    return getCharacteristic(services, (service, characteristic) => isCyclingPowerMeasurementCharacteristic(service, characteristic));
  }

  static bool isCyclingPowerMeasurementCharacteristic(GattService service, GattCharacteristic characteristic) {
    return service.uuid == cyclingPowerMeasurementServiceUUID &&
        characteristic.uuid == cyclingPowerMeasurementCharacteristicUUID;
  }

  static GattCharacteristic? getFitnessMachineControlPointCharacteristic(List<GattService> services) {
    return getCharacteristic(services, (service, characteristic) => isFitnessMachineControlPointCharacteristic(service, characteristic));
  }

  static bool isFitnessMachineControlPointCharacteristic(GattService service, GattCharacteristic characteristic) {
    return service.uuid == fitnessMachineServiceUUID &&
        characteristic.uuid == fitnessMachineControlPointCharacteristicUUID;
  }

  static GattCharacteristic? getCharacteristic(List<GattService> services, bool Function(dynamic service, dynamic characteristic) isRequiredPredicate) {
    for (GattService service in services) {
      for (GattCharacteristic characteristic in service.characteristics) {
        if (isRequiredPredicate(service, characteristic)) {
          print("Found characteristic: ${characteristic.uuid}");
          return characteristic;
        }
      }
    }
    throw("Didn't find characteristic");
  }

}
