import 'dart:async';

import 'package:simple_pid/simple_pid.dart';

import '../devices/HeartRateDevice.dart';
import '../devices/IndoorBikeDevice.dart';

class ExerciseCore {
  final HeartRateDevice _heartRateBluetoothDevice;
  final IndoorBikeDevice _indoorBikeBluetoothDevice;

  int heartRateTarget = 125;

  ExerciseCore(this._heartRateBluetoothDevice, this._indoorBikeBluetoothDevice, {heartRateTarget});

  late PID pid;
  Timer? timer;

  int _currentPowerSetpoint = 0;
  int _currentPowerActual = 0;
  int _heartRateValue = 0;

  double minPower = 100;
  double maxPower = 250;

  StreamController<ExerciseData> streamController = StreamController<ExerciseData>();

  Future<Stream<ExerciseData>> init() async {
    pid = PID(Kp: 1, Ki: 0.1, Kd: 0.05, setPoint: heartRateTarget.toDouble(), minOutput: minPower, maxOutput: maxPower);

    await startReadingHeartRate();
    await startReadingAcutalPower();
    setPower(minPower.toInt());
    return streamController.stream;
  }

  void start() {
    timer = Timer.periodic(const Duration(seconds: 1), performPeriodicTasks);
  }

  void pause() {
    if (timer!= null){
      timer!.cancel();
    }
  }

  Future<void> startReadingAcutalPower() async {
    await _indoorBikeBluetoothDevice.connect();
    _indoorBikeBluetoothDevice.getListener().listen((value) {
      print("Power received $value");
      _currentPowerActual = value;
    });
  }

  Future<void> startReadingHeartRate() async {
    await _heartRateBluetoothDevice.connect();
    await _heartRateBluetoothDevice.getListener().listen((value) {
      print("Heart rate received $value");
      _heartRateValue = value;
    });
  }

  void performPeriodicTasks(Timer timer) {
    _currentPowerSetpoint = pid(_heartRateValue.toDouble()).toInt();
    setPower(_currentPowerSetpoint);
    var exerciseSample = ExerciseData(_currentPowerSetpoint, _currentPowerActual, _heartRateValue);
    print("Periodic data: $_currentPowerSetpoint $_currentPowerActual $_heartRateValue");
    streamController.add(exerciseSample);
  }

  void setPower(int power) {
    print("setting power: $power");
    _indoorBikeBluetoothDevice.setTargetPower(power);
  }

  void dispose() {
    _heartRateBluetoothDevice.disconnect();
    _indoorBikeBluetoothDevice.disconnect();
    pause();
  }

  void setHeartRateTarget(int value) {
    heartRateTarget = value;
    pid.setPoint = heartRateTarget.toDouble();
  }
}

class ExerciseData {
  int powerSetpoint;
  int powerActual;
  int heartRateValue;

  ExerciseData(this.powerSetpoint, this.powerActual, this.heartRateValue);
}
