import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zone_2_training/devices/BluetoothHeartRateDevice.dart';
import 'package:zone_2_training/devices/BluetoothIndoorBikeDevice.dart';
import 'package:zone_2_training/preferences.dart';

import 'core/ExerciseCore.dart';
import 'devices/SimHeartRateDevice.dart';
import 'devices/SimIndoorBikeDevice.dart';

class ExerciseScreen extends StatefulWidget {
  final BluetoothDevice hrmBluetoothDevice;
  final BluetoothDevice indoorBikeBluetoothDevice;

  const ExerciseScreen(this.hrmBluetoothDevice, this.indoorBikeBluetoothDevice, {super.key});

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState(hrmBluetoothDevice, indoorBikeBluetoothDevice);
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  BluetoothDevice hrmBluetoothDevice;
  BluetoothDevice indoorBikeBluetoothDevice;

  _ExerciseScreenState(this.hrmBluetoothDevice, this.indoorBikeBluetoothDevice);

  late ExerciseCore _exerciseCore;
  late SharedPreferences prefs;

  int _currentPowerSetpoint = 0;
  int _currentPowerActual = 0;
  int _heartRateValue = 0;

  int _heartRateTarget = 140;

  int sampleCount = 0;
  List<SampledData> heartRateSamples = <SampledData>[];
  List<SampledData> powerSetPointSamples = <SampledData>[];
  List<SampledData> powerActualSamples = <SampledData>[];
  List<SampledData> heartRateTargetSamples = <SampledData>[];

  ChartSeriesController<SampledData, int>? _heartRateChartSeriesController;
  ChartSeriesController<SampledData, int>? _powerSetPointChartSeriesController;
  ChartSeriesController<SampledData, int>? _powerAcutalChartSeriesController;
  ChartSeriesController<SampledData, int>? _heartRateTargetChartSeriesController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Session'),
      ),
      body: Column(
        children: [
          Text("Heart rate: $_heartRateValue"),
          Text("Actual Power: $_currentPowerActual"),
          Text("Current Power setpoint: $_currentPowerSetpoint"),
          const Divider(),
          buildChart(context),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    _exerciseCore.heartRateTarget -= 1;
                    _exerciseCore.setHeartRateTarget(_exerciseCore.heartRateTarget);
                    setState(() {
                      _heartRateTarget = _exerciseCore.heartRateTarget;
                    });
                  },
                  icon: const Icon(Icons.arrow_back_sharp)),
              Expanded(
                child: Column(children: [
                  const Text("Heart Rate Setpoint", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("$_heartRateTarget", style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ),
              IconButton(
                  onPressed: () {
                    _exerciseCore.heartRateTarget += 1;
                    _exerciseCore.setHeartRateTarget(_exerciseCore.heartRateTarget);
                    setState(() {
                      _heartRateTarget = _exerciseCore.heartRateTarget;
                    });
                  },
                  icon: const Icon(Icons.arrow_forward_sharp)),
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    KeepScreenOn.turnOn();
    startRuntime();
  }

  Future<void> startRuntime() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(PreferenceConstants.SIM_MODE) ?? true) {
      print("SIM MODE ENABLED");
      var simIndoorBikeDevice = SimIndoorBikeDevice();
      var simHeartRateDevice = SimHeartRateDevice(simIndoorBikeDevice.getListener());
      _exerciseCore = ExerciseCore(simHeartRateDevice, simIndoorBikeDevice, heartRateTarget: _heartRateTarget);
    } else {
      _exerciseCore = ExerciseCore(BluetoothHeartRateDevice(hrmBluetoothDevice), BluetoothIndoorBikeDevice(indoorBikeBluetoothDevice),
          heartRateTarget: _heartRateTarget);
    }
    Stream<ExerciseSample> exerciseSampleStream = _exerciseCore.start();
    exerciseSampleStream.listen((exerciseSample) {
      setState(() {
        _heartRateValue = exerciseSample.heartRateValue;
        _currentPowerActual = exerciseSample.powerActual;
        _currentPowerSetpoint = exerciseSample.powerSetpoint;
        updateChart();
      });
    });
  }

  @override
  void dispose() {
    KeepScreenOn.turnOff();
    _exerciseCore.dispose();
    super.dispose();
  }

  Widget buildChart(BuildContext context) {
    return SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: const NumericAxis(majorGridLines: MajorGridLines(width: 0)),
        primaryYAxis: const NumericAxis(maximum: 250, axisLine: AxisLine(width: 0), majorTickLines: MajorTickLines(size: 0)),
        series: <LineSeries<SampledData, int>>[
          LineSeries<SampledData, int>(
            onRendererCreated: (ChartSeriesController<SampledData, int> controller) {
              _heartRateChartSeriesController = controller;
            },
            dataSource: heartRateSamples,
            color: Colors.red,
            xValueMapper: (SampledData data, _) => data.sampleNumber,
            yValueMapper: (SampledData data, _) => data.value,
            animationDuration: 0,
          ),
          LineSeries<SampledData, int>(
            onRendererCreated: (ChartSeriesController<SampledData, int> controller) {
              _powerSetPointChartSeriesController = controller;
            },
            dataSource: powerSetPointSamples,
            color: Colors.blue,
            xValueMapper: (SampledData data, _) => data.sampleNumber,
            yValueMapper: (SampledData data, _) => data.value,
            animationDuration: 0,
          ),
          LineSeries<SampledData, int>(
            onRendererCreated: (ChartSeriesController<SampledData, int> controller) {
              _powerAcutalChartSeriesController = controller;
            },
            dataSource: powerActualSamples,
            color: Colors.green,
            xValueMapper: (SampledData data, _) => data.sampleNumber,
            yValueMapper: (SampledData data, _) => data.value,
            animationDuration: 0,
          ),
          LineSeries<SampledData, int>(
            onRendererCreated: (ChartSeriesController<SampledData, int> controller) {
              _heartRateTargetChartSeriesController = controller;
            },
            dataSource: heartRateTargetSamples,
            color: Colors.red,
            dashArray: const <double>[4, 5],
            xValueMapper: (SampledData data, _) => data.sampleNumber,
            yValueMapper: (SampledData data, _) => data.value,
            animationDuration: 0,
          ),
        ]);
  }

  void updateChart() {
    heartRateSamples.add(SampledData(sampleNumber: sampleCount, value: _heartRateValue));
    powerSetPointSamples.add(SampledData(sampleNumber: sampleCount, value: _currentPowerSetpoint));
    powerActualSamples.add(SampledData(sampleNumber: sampleCount, value: _currentPowerActual));
    heartRateTargetSamples.add(SampledData(sampleNumber: sampleCount, value: _heartRateTarget));

    var chartDataMax = 60 * 5;
    if (heartRateSamples.length == chartDataMax) {
      heartRateSamples.removeAt(0);
      _heartRateChartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[heartRateSamples.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _heartRateChartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[heartRateSamples.length - 1],
      );
    }
    if (powerSetPointSamples.length == chartDataMax) {
      powerSetPointSamples.removeAt(0);
      _powerSetPointChartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[powerSetPointSamples.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _powerSetPointChartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[powerSetPointSamples.length - 1],
      );
    }
    if (powerActualSamples.length == chartDataMax) {
      powerActualSamples.removeAt(0);
      _powerAcutalChartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[powerActualSamples.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _powerAcutalChartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[powerActualSamples.length - 1],
      );
    }
    if (heartRateTargetSamples.length == chartDataMax) {
      heartRateTargetSamples.removeAt(0);
      _heartRateTargetChartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[heartRateTargetSamples.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _heartRateTargetChartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[heartRateTargetSamples.length - 1],
      );
    }
    sampleCount = sampleCount + 1;
  }
}

class SampledData {
  late int sampleNumber;
  late int value;

  SampledData({required this.sampleNumber, required this.value});
}
