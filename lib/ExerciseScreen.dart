import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:simple_pid/simple_pid.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zone_2_training/devices/BluetoothHeartRateDevice.dart';
import 'package:zone_2_training/devices/BluetoothIndoorBikeDevice.dart';

import 'core/ExerciseCore.dart';
import 'devices/HeartRateDevice.dart';
import 'devices/IndoorBikeDevice.dart';

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
  late HeartRateDevice _heartRateDevice;
  late IndoorBikeDevice _indoorBikeDevice;

  int _currentPowerSetpoint = 0;
  int _currentPowerActual = 0;
  int _heartRateValue = 0;

  int heartRateTarget = 70;

  int sampleCount = 0;
  List<SampledData> heartRateSamples = <SampledData>[];
  List<SampledData> powerSetPointSamples = <SampledData>[];
  List<SampledData> powerActualSamples = <SampledData>[];
  ChartSeriesController<SampledData, int>? _chartSeriesController;

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
          const Divider(
            color: Colors.blue,
          ),
          buildChart(context),
          Row(
            children: [
              IconButton(onPressed: () => {}, icon: const Icon(Icons.arrow_back_sharp)),
              Expanded(
                child: Column(children: [
                  const Text("Heart Rate Setpoint", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("$heartRateTarget", style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ),
              IconButton(onPressed: () => {}, icon: const Icon(Icons.arrow_forward_sharp)),
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _exerciseCore = ExerciseCore(BluetoothHeartRateDevice(hrmBluetoothDevice), BluetoothIndoorBikeDevice(indoorBikeBluetoothDevice));
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
    _exerciseCore.dispose();
    super.dispose();
  }

  Widget buildChart(BuildContext context) {
    return SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: const NumericAxis(majorGridLines: MajorGridLines(width: 0)),
        primaryYAxis:
            NumericAxis(maximum: 250, axisLine: const AxisLine(width: 0), majorTickLines: const MajorTickLines(size: 0), plotBands: <PlotBand>[
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
            dataSource: powerSetPointSamples,
            color: Colors.blue,
            xValueMapper: (SampledData data, _) => data.sampleNumber,
            yValueMapper: (SampledData data, _) => data.value,
            animationDuration: 0,
          ),
          LineSeries<SampledData, int>(
            onRendererCreated: (ChartSeriesController<SampledData, int> controller) {
              _chartSeriesController = controller;
            },
            dataSource: powerActualSamples,
            color: Colors.green,
            xValueMapper: (SampledData data, _) => data.sampleNumber,
            yValueMapper: (SampledData data, _) => data.value,
            animationDuration: 0,
          )
        ]);
  }

  void updateChart() {
    heartRateSamples!.add(SampledData(sampleNumber: sampleCount, value: _heartRateValue));
    powerSetPointSamples!.add(SampledData(sampleNumber: sampleCount, value: _currentPowerSetpoint));
    powerActualSamples!.add(SampledData(sampleNumber: sampleCount, value: _currentPowerActual));

    var chartDataMax = 60 * 5;
    if (heartRateSamples!.length == chartDataMax) {
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
    if (powerSetPointSamples!.length == chartDataMax) {
      powerSetPointSamples!.removeAt(0);
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[powerSetPointSamples!.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[powerSetPointSamples!.length - 1],
      );
    }
    if (powerActualSamples!.length == chartDataMax) {
      powerActualSamples!.removeAt(0);
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[powerActualSamples!.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[powerActualSamples!.length - 1],
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
