import 'dart:async';
import 'package:zone_2_training/devices/DeviceDataProvider.dart';

class SimDevices implements DeviceDataProvider {
  late StreamController<int> heartRateStreamController;
  late StreamController<int> powerRateStreamController;
  late Timer timer;

  SimDevices() {
    heartRateStreamController = StreamController<int>();
    powerRateStreamController = StreamController<int>();

    timer = Timer.periodic(const Duration(seconds: 1), sendHeartRate);
  }

  int currentPower = 0;
  int stablePower = 140;
  int currentHeartRate = 50;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {
    timer.cancel();
    heartRateStreamController.close();
    powerRateStreamController.close();
  }

  @override
  Stream<int> getHeartRateStream() {
    return heartRateStreamController.stream.asBroadcastStream();
  }

  @override
  Stream<int> getPowerStream() {
    return powerRateStreamController.stream.asBroadcastStream();
  }

  @override
  void setPower(int power) {
    currentPower = power;
    powerRateStreamController.add(power);
  }

  void sendHeartRate(Timer timer) {
    if (currentPower > stablePower) {
      currentHeartRate++;
    } else {
      currentHeartRate--;
    }
    heartRateStreamController.add(currentHeartRate);
  }
}
