import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:simple_pid/simple_pid.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'BluetoothUtils.dart';

class ExerciseScreen extends StatefulWidget {
  final String hrmBluetoothRemoteIdStr;
  final String indoorBikeBluetoothRemoteIdStr;

  const ExerciseScreen(this.hrmBluetoothRemoteIdStr, this.indoorBikeBluetoothRemoteIdStr, {super.key});

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState(hrmBluetoothRemoteIdStr, indoorBikeBluetoothRemoteIdStr);
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String hrmBluetoothRemoteIdStr;
  String indoorBikeBluetoothRemoteIdStr;

  _ExerciseScreenState(this.hrmBluetoothRemoteIdStr, this.indoorBikeBluetoothRemoteIdStr);

  int heartRateValue = 0;
  int heartRateTarget = 70;
  late BluetoothDevice hrmBluetoothDevice;

  double minPower = 100;
  double maxPower = 220;

  late PID pid;

  Timer? timer;
  List<SampledData>? heartRateSamples;
  List<SampledData>? powerSamples;
  late int count;
  ChartSeriesController<SampledData, int>? _chartSeriesController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Session'),
      ),
      body: Column(
        children: [
          Text("Heart rate: $heartRateValue"),
          const Divider(
            color: Colors.blue,
          ),
          buildChart(context),
        ],
      ),
    );
  }

  @override
  void initState() {
    count = 0;
    heartRateSamples = <SampledData>[];
    powerSamples = <SampledData>[];
    super.initState();
    startReadingHR();
  }

  @override
  void dispose() {
    hrmBluetoothDevice.disconnect();
    super.dispose();
  }

  Widget buildChart(BuildContext context) {
    return SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: const NumericAxis(majorGridLines: MajorGridLines(width: 0)),
        primaryYAxis: NumericAxis(maximum: 250, axisLine: const AxisLine(width: 0), majorTickLines: const MajorTickLines(size: 0), plotBands: <PlotBand>[
          PlotBand(start: heartRateTarget, end: heartRateTarget, borderWidth: 2, borderColor: Colors.redAccent, dashArray: const <double>[4, 5])
        ]),
        series: <LineSeries<SampledData, int>>[
          LineSeries<SampledData, int>(
            onRendererCreated: (ChartSeriesController<SampledData, int> controller) {
              _chartSeriesController = controller;
            },
            dataSource: heartRateSamples,
            color: Colors.red,
            xValueMapper: (SampledData data, _) => data.sampleNumber,
            yValueMapper: (SampledData data, _) => data.value,
            animationDuration: 0,
          ),
          LineSeries<SampledData, int>(
            onRendererCreated: (ChartSeriesController<SampledData, int> controller) {
              _chartSeriesController = controller;
            },
            dataSource: powerSamples,
            color: Colors.blue,
            xValueMapper: (SampledData data, _) => data.sampleNumber,
            yValueMapper: (SampledData data, _) => data.value,
            animationDuration: 0,
          )
        ]);
  }

  void startReadingHR() async {
    hrmBluetoothDevice = BluetoothDevice.fromId(hrmBluetoothRemoteIdStr);
    await hrmBluetoothDevice.connect();
    await hrmBluetoothDevice.discoverServices();
    List<BluetoothService> services = await hrmBluetoothDevice.discoverServices();
    BluetoothCharacteristic? bluetoothCharacteristic = BluetoothUtils.getHeartRateMeasurementCharacteristic(services);
    bluetoothCharacteristic?.onValueReceived.listen((value) {
      print("New heart rate value received $value");
      setState(() {
        heartRateValue = value[1];
      });
    });
    await bluetoothCharacteristic?.setNotifyValue(true);
    pid = PID(Kp: 1, Ki: 0.1, Kd: 0.05, setPoint: heartRateTarget.toDouble(), minOutput: minPower, maxOutput: maxPower);
    timer = Timer.periodic(const Duration(seconds: 1), _updateDataSource);
  }

  void _updateDataSource(Timer timer) {
    int currentPowerSetpoint = pid(heartRateValue.toDouble()).toInt();

    heartRateSamples!.add(SampledData(sampleNumber: count, value: heartRateValue));
    powerSamples!.add(SampledData(sampleNumber: count, value: currentPowerSetpoint));
    if (heartRateSamples!.length == 60 * 5) {
      heartRateSamples!.removeAt(0);
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[heartRateSamples!.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[heartRateSamples!.length - 1],
      );
    }
    count = count + 1;
  }
}

class SampledData {
  late int sampleNumber;
  late int value;

  SampledData({required this.sampleNumber, required this.value});
}
