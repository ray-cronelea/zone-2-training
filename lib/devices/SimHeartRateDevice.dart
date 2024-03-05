import 'dart:async';
import 'HeartRateDevice.dart';

class SimHeartRateDevice implements HeartRateDevice {
  StreamController<int> controller = StreamController<int>();
  int currentHeartRate = 50;
  int simPower = 195;
  late Timer timer;

  SimHeartRateDevice(Stream<int> listener) {
    timer = Timer.periodic(const Duration(seconds: 1), sendHeartRate);
    listener.listen((currentPower) {
      if (currentPower > simPower) {
        currentHeartRate++;
      } else {
        currentHeartRate--;
      }

      controller.add(currentHeartRate);
    });
  }

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Stream<int> getListener() {
    return controller.stream.asBroadcastStream();
  }

  void sendHeartRate(Timer timer) {
    controller.add(currentHeartRate);
  }
}
