import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:simple_pid/simple_pid.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'BluetoothUtils.dart';

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

  int heartRateValue = 0;
  int heartRateTarget = 70;

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
          Row(
            children: [
              IconButton(onPressed: () => {}, icon: Icon(Icons.arrow_back_sharp)),
              Expanded(
                child: Column(children: [
                  const Text("Heart Rate Setpoint", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("$heartRateTarget", style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ),
              IconButton(onPressed: () => {}, icon: Icon(Icons.arrow_forward_sharp)),
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    count = 0;
    heartRateSamples = <SampledData>[];
    powerSamples = <SampledData>[];
    pid = PID(Kp: 1, Ki: 0.1, Kd: 0.05, setPoint: heartRateTarget.toDouble(), minOutput: minPower, maxOutput: maxPower);

    startReadingHeartRate();

    timer = Timer.periodic(const Duration(seconds: 1), periodicTasks);
  }

  @override
  void dispose() {
    hrmBluetoothDevice.disconnect();
    indoorBikeBluetoothDevice.disconnect();
    timer?.cancel();
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
            dataSource: powerSamples,
            color: Colors.blue,
            xValueMapper: (SampledData data, _) => data.sampleNumber,
            yValueMapper: (SampledData data, _) => data.value,
            animationDuration: 0,
          )
        ]);
  }

  Future<void> startReadingHeartRate() async {
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
  }

  void periodicTasks(Timer timer) {
    int currentPowerSetpoint = pid(heartRateValue.toDouble()).toInt();
    // TODO: send currentPowerSetpoint value to trainer
    updateChart(currentPowerSetpoint);
  }

  void updateChart(int currentPowerSetpoint) {
    heartRateSamples!.add(SampledData(sampleNumber: count, value: heartRateValue));
    powerSamples!.add(SampledData(sampleNumber: count, value: currentPowerSetpoint));

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
    if (powerSamples!.length == chartDataMax) {
      powerSamples!.removeAt(0);
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[powerSamples!.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[powerSamples!.length - 1],
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
