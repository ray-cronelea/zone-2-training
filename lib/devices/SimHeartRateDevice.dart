import 'dart:async';
import 'HeartRateDevice.dart';

class SimHeartRateDevice implements HeartRateDevice {
  StreamController<int> controller = StreamController<int>();
  int currentHeartRate = 50;
  int simPower = 195;

  SimHeartRateDevice(Stream<int> listener) {
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
}
