import 'dart:async';
import 'IndoorBikeDevice.dart';

class SimIndoorBikeDevice implements IndoorBikeDevice {
  SimIndoorBikeDevice(){
    asBroadcastStream = controller.stream.asBroadcastStream();
  }

  StreamController<int> controller = StreamController<int>();
  late Stream<int> asBroadcastStream;

  @override
  Future<void> connect() async {
  }

  @override
  Future<void> disconnect() async {}

  @override
  Stream<int> getListener() {
    return asBroadcastStream;
  }

  @override
  Future<void> setTargetPower(int targetPower) async {
    controller.sink.add(targetPower);
  }
}
