import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zone_2_training/devices/HeartRateDevice.dart';
import 'package:zone_2_training/devices/IndoorBikeDevice.dart';
import 'core/ExerciseCore.dart';

class ExerciseScreen extends StatefulWidget {
  final HeartRateDevice heartRateDevice;
  final IndoorBikeDevice indoorBikeDevice;

  const ExerciseScreen(this.heartRateDevice, this.indoorBikeDevice, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _ExerciseScreenState(heartRateDevice, indoorBikeDevice);
  }
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  HeartRateDevice heartRateDevice;
  IndoorBikeDevice indoorBikeDevice;

  _ExerciseScreenState(this.heartRateDevice, this.indoorBikeDevice);

  late ExerciseCore _exerciseCore;
  late SharedPreferences prefs;

  int _currentPowerSetpoint = 0;
  int _currentPowerActual = 0;
  int _heartRateValue = 0;
  int _heartRateTarget = 140;

  bool running = false;

  int sampleCount = 0;
  List<SampledData> heartRateSamples = <SampledData>[];
  List<SampledData> powerSetPointSamples = <SampledData>[];
  List<SampledData> powerActualSamples = <SampledData>[];
  List<SampledData> heartRateTargetSamples = <SampledData>[];

  ChartSeriesController<SampledData, int>? _heartRateChartSeriesController;
  ChartSeriesController<SampledData, int>? _powerSetPointChartSeriesController;
  ChartSeriesController<SampledData, int>? _powerActualChartSeriesController;
  ChartSeriesController<SampledData, int>? _heartRateTargetChartSeriesController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Session'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          buildTopDetail(),
          Expanded(
            child: Column(
              children: [
                buildPowerChart(context),
                Container(
                  height: 10,
                ),
                buildHeartRateChart(context),
              ],
            ),
          ),
          buildHeartRateSetpointController(),
          Container(height: 30)
        ],
      ),
      bottomNavigationBar: buildBottomAppBar(context),
    );
  }

  Widget buildTopDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(children: [
          const Text("Heart Rate", style: TextStyle(fontWeight: FontWeight.normal)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Transform.scale(scale: 2.0, child: Text("$_heartRateValue", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
          ),
          Text("BPM", style: const TextStyle(fontWeight: FontWeight.normal)),
        ]),
        Column(children: [
          const Text("Power", style: TextStyle(fontWeight: FontWeight.normal)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Transform.scale(
                scale: 2.0, child: Text("$_heartRateTarget", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
          ),
          Text("WATT", style: const TextStyle(fontWeight: FontWeight.normal)),
        ]),
      ],
    );
  }

  Row buildHeartRateSetpointController() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: IconButton.outlined(
              onPressed: () {
                _exerciseCore.heartRateTarget -= 1;
                _exerciseCore.setHeartRateTarget(_exerciseCore.heartRateTarget);
                setState(() {
                  _heartRateTarget = _exerciseCore.heartRateTarget;
                });
              },
              icon: Transform.scale(scale: 2.0, child: Icon(Icons.remove))),
        ),
        Expanded(
          child: Column(children: [
            const Text("Setpoint", style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Transform.scale(
                  scale: 2.0, child: Text("$_heartRateTarget", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
            ),
            Text("BPM", style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: IconButton.outlined(
              onPressed: () {
                _exerciseCore.heartRateTarget += 1;
                _exerciseCore.setHeartRateTarget(_exerciseCore.heartRateTarget);
                setState(() {
                  _heartRateTarget = _exerciseCore.heartRateTarget;
                });
              },
              icon: Transform.scale(scale: 2.0, child: Icon(Icons.add))),
        ),
      ],
    );
  }

  // return Navigator.pop(context);

  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          children: <Widget>[
            OutlinedButton(
              child: const Icon(Icons.stop),
              onPressed: () async {
                return await showStopDialog(context);
              },
            ),
            const Spacer(),
            Builder(builder: (context) {
              if (running) {
                return Text("Running");
              } else {
                return Text("Paused");
              }
            }),
            const Spacer(),
            Builder(builder: (context) {
              if (running) {
                return OutlinedButton(
                    child: const Icon(Icons.pause_outlined),
                    onPressed: () {
                      pauseRuntime();
                    });
              } else {
                return OutlinedButton(
                    child: const Icon(Icons.play_arrow_outlined),
                    onPressed: () {
                      startRuntime();
                    });
              }
            }),
          ],
        ),
      ),
    );
  }

  showStopDialog(BuildContext context) async {
    bool? closeScreen = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('Are you sure you want to finish the exercise?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
        ],
      ),
    );
    if (closeScreen ?? false) {
      return Navigator.pop(context);
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    KeepScreenOn.turnOn();
    initRuntime();
  }

  Future<void> initRuntime() async {
    _exerciseCore = ExerciseCore(heartRateDevice, indoorBikeDevice, heartRateTarget: _heartRateTarget);

    Stream<ExerciseData> exerciseDataStream = _exerciseCore.init();
    exerciseDataStream.listen((exerciseSample) {
      setState(() {
        _heartRateValue = exerciseSample.heartRateValue;
        _currentPowerActual = exerciseSample.powerActual;
        _currentPowerSetpoint = exerciseSample.powerSetpoint;
        updateChart();
      });
    });
  }

  void startRuntime() {
    _exerciseCore.start();
    setState(() {
      running = true;
    });
  }

  void pauseRuntime() {
    _exerciseCore.pause();
    setState(() {
      running = false;
    });
  }

  @override
  void dispose() {
    KeepScreenOn.turnOff();
    _exerciseCore.dispose();
    super.dispose();
  }

  Widget buildPowerChart(BuildContext context) {
    return SizedBox(
      height: 250,
      child: SfCartesianChart(
          annotations: [CartesianChartAnnotation(widget: Text("Power"), x: "50%", y: "80%", coordinateUnit : CoordinateUnit.percentage,)],
          plotAreaBorderWidth: 0,
          primaryXAxis: const NumericAxis(majorGridLines: MajorGridLines(width: 0)),
          primaryYAxis: const NumericAxis(maximum: 250, axisLine: AxisLine(width: 0), majorTickLines: MajorTickLines(size: 0)),
          series: <LineSeries<SampledData, int>>[
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
                _powerActualChartSeriesController = controller;
              },
              dataSource: powerActualSamples,
              color: Colors.green,
              xValueMapper: (SampledData data, _) => data.sampleNumber,
              yValueMapper: (SampledData data, _) => data.value,
              animationDuration: 0,
            ),
          ]),
    );
  }

  Widget buildHeartRateChart(BuildContext context) {
    return SizedBox(
      height: 250,
      child: SfCartesianChart(
          annotations: [CartesianChartAnnotation(widget: Text("Heart Rate"), x: "50%", y: "80%", coordinateUnit : CoordinateUnit.percentage,)],
          plotAreaBorderWidth: 0,
          primaryXAxis: const NumericAxis(majorGridLines: MajorGridLines(width: 0)),
          primaryYAxis: const NumericAxis(maximum: 200, axisLine: AxisLine(width: 0), majorTickLines: MajorTickLines(size: 0)),
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
                _heartRateTargetChartSeriesController = controller;
              },
              dataSource: heartRateTargetSamples,
              color: Colors.orange,
              xValueMapper: (SampledData data, _) => data.sampleNumber,
              yValueMapper: (SampledData data, _) => data.value,
              animationDuration: 0,
            ),
          ]),
    );
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
      _powerActualChartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[powerActualSamples.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _powerActualChartSeriesController?.updateDataSource(
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
