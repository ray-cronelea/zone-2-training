import 'dart:async';
import 'dart:typed_data';

import 'package:universal_ble/universal_ble.dart';
import 'package:zone_2_training/devices/BluetoothLowEnergyUtils.dart';
import 'package:zone_2_training/devices/DeviceDataProvider.dart';

class BluetoothDevices implements DeviceDataProvider {
  String heartRateDeviceId;
  String powerRateDeviceId;

  late StreamController<int> heartRateStreamController;
  late StreamController<int> powerRateStreamController;

  BluetoothDevices(this.heartRateDeviceId, this.powerRateDeviceId) {
    heartRateStreamController = StreamController<int>();
    powerRateStreamController = StreamController<int>();
  }

  @override
  Future<void> connect() async {
    UniversalBle.onConnectionChanged = _handleConnectionChange;
    UniversalBle.onValueChanged = _handleValueChange;
    UniversalBle.onPairingStateChange = _handlePairingStateChange;

    await UniversalBle.connect(heartRateDeviceId);
    await UniversalBle.connect(powerRateDeviceId);
  }

  @override
  Future<void> disconnect() async {
    UniversalBle.onConnectionChanged = null;
    UniversalBle.onValueChanged = null;

    await UniversalBle.disconnect(heartRateDeviceId);
    await UniversalBle.disconnect(powerRateDeviceId);
  }

  @override
  Stream<int> getHeartRateStream() {
    return heartRateStreamController.stream;
  }

  @override
  Stream<int> getPowerStream() {
    return powerRateStreamController.stream;
  }

  @override
  void setPower(int power) {

    // request control
    UniversalBle.writeValue(
      powerRateDeviceId,
      BluetoothLowEnergyUtils.fitnessMachineServiceUUID,
      BluetoothLowEnergyUtils.fitnessMachineControlPointCharacteristicUUID,
      Uint8List.fromList([0]),
      BleOutputProperty.withResponse,
    );


    //List<int> currentPowerSetpointBytes = toUint8List(currentPowerSetpoint);
    // Write setpoint
    UniversalBle.writeValue(
      powerRateDeviceId,
      BluetoothLowEnergyUtils.fitnessMachineServiceUUID,
      BluetoothLowEnergyUtils.fitnessMachineControlPointCharacteristicUUID,
      Uint8List.fromList([5, power, 0]),
      BleOutputProperty.withResponse,
    );
  }

  Future<void> _handleConnectionChange(String deviceId, BleConnectionState state) async {
    print('_handleConnectionChange $deviceId, ${state.name}');
    // Auto Discover Services
    if ((state == BleConnectionState.connected)) {
      await _discoverServices(deviceId);

      // Set notifications for required data based on device

      if (deviceId == heartRateDeviceId) {
        await UniversalBle.setNotifiable(
          heartRateDeviceId,
          BluetoothLowEnergyUtils.heartRateMeasurementServiceUUID,
          BluetoothLowEnergyUtils.heartrateMeasurementCharacteristicUUID,
          BleInputProperty.notification,
        );
      }

      if (deviceId == powerRateDeviceId) {
        await UniversalBle.setNotifiable(
          powerRateDeviceId,
          BluetoothLowEnergyUtils.cyclingPowerMeasurementServiceUUID,
          BluetoothLowEnergyUtils.cyclingPowerMeasurementCharacteristicUUID,
          BleInputProperty.notification,
        );
      }
    }
  }

  bool equalsIgnoreCase(String? string1, String? string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  void _handleValueChange(String deviceId, String characteristicId, Uint8List value) {
    String s = String.fromCharCodes(value);
    print('_handleValueChange $deviceId, $characteristicId, $s');

    if ((equalsIgnoreCase(deviceId,heartRateDeviceId)) && (equalsIgnoreCase(characteristicId,BluetoothLowEnergyUtils.heartrateMeasurementCharacteristicUUID))) {
      heartRateStreamController.add(value[1]);
    }

    if (equalsIgnoreCase(deviceId,powerRateDeviceId) && equalsIgnoreCase(characteristicId, BluetoothLowEnergyUtils.cyclingPowerMeasurementCharacteristicUUID)) {
      powerRateStreamController.add(_getCurrentActualPower(value));
    }
  }

  int _getCurrentActualPower(List<int> value) {
    int powerLSB = value[2];
    int powerMSB = value[3];
    return (powerMSB << 8) + powerLSB;
  }

  void _handlePairingStateChange(String deviceId, bool isPaired, String? error) {
    print('OnPairStateChange $deviceId, $isPaired, ${error}');
  }

  Future<void> _discoverServices(String deviceId) async {
    List<BleService> services = await UniversalBle.discoverServices(deviceId);
    print('${services.length} services discovered for device id $deviceId');
    BluetoothLowEnergyUtils.printServices(services);
  }
}
