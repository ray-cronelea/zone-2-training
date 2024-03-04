import 'dart:async';

import 'package:simple_pid/simple_pid.dart';

import '../devices/HeartRateDevice.dart';
import '../devices/IndoorBikeDevice.dart';

class ExerciseCore {
  final HeartRateDevice _heartRateBluetoothDevice;
  final IndoorBikeDevice _indoorBikeBluetoothDevice;

  int heartRateTarget = 140;

  ExerciseCore(this._heartRateBluetoothDevice, this._indoorBikeBluetoothDevice, {heartRateTarget});

  late PID pid;
  late Timer timer;

  int _currentPowerSetpoint = 0;
  int _currentPowerActual = 0;
  int _heartRateValue = 0;

  double minPower = 100;
  double maxPower = 220;

  StreamController<ExerciseSample> streamController = StreamController<ExerciseSample>();

  Stream<ExerciseSample> start() {
    pid = PID(Kp: 1, Ki: 0.1, Kd: 0.05, setPoint: heartRateTarget.toDouble(), minOutput: minPower, maxOutput: maxPower);

    startReadingHeartRate();
    startReadingAcutalPower();

    timer = Timer.periodic(const Duration(seconds: 1), performPeriodicTasks);

    return streamController.stream;
  }

  Future<void> startReadingAcutalPower() async {
    await _indoorBikeBluetoothDevice.connect();
    _indoorBikeBluetoothDevice.getListener().listen((value) {
      _currentPowerActual = value;
    });
  }

  Future<void> startReadingHeartRate() async {
    await _heartRateBluetoothDevice.connect();
    _heartRateBluetoothDevice.getListener().listen((value) {
      print("Heart rate received $value");
      _heartRateValue = value;
    });
  }

  void performPeriodicTasks(Timer timer) {
    _currentPowerSetpoint = pid!(_heartRateValue.toDouble()).toInt();
    _indoorBikeBluetoothDevice.setTargetPower(_currentPowerSetpoint);
    print("New power: $_currentPowerSetpoint");
    var exerciseSample = ExerciseSample(_currentPowerSetpoint, _currentPowerActual, _heartRateValue);
    streamController.add(exerciseSample);
  }

  void dispose() {
    _heartRateBluetoothDevice.disconnect();
    _indoorBikeBluetoothDevice.disconnect();
    timer?.cancel();
  }

  void setHeartRateTarget(int value){
    heartRateTarget = value;
    pid.setPoint = heartRateTarget.toDouble();
  }

}

class ExerciseSample {
  int powerSetpoint;
  int powerActual;
  int heartRateValue;

  ExerciseSample(this.powerSetpoint, this.powerActual, this.heartRateValue);
}
