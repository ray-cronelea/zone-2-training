import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:zone_2_training/preferences.dart';

class BluetoothSelectionScreen extends StatefulWidget {
  const BluetoothSelectionScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BluetoothSelectionScreenState();
}

class _BluetoothSelectionScreenState extends State<BluetoothSelectionScreen> {
  late final ValueNotifier<AvailabilityState> state;
  late final ValueNotifier<bool> discovering;
  late final ValueNotifier<List<BleScanResult>> bleScanResults;

  bool simMode = false;

  @override
  void dispose() {
    super.dispose();
    state.dispose();
    discovering.dispose();
    bleScanResults.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a bluetooth device'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildBluetoothStatusMessage(context),
            _buildSimButton(context),
            _buildListView(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () async {
          if (discovering.value) {
            await stopDiscovery();
            await startDiscovery();
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _performSimModeTasks();

    state = ValueNotifier(AvailabilityState.unknown);

    discovering = ValueNotifier(false);
    bleScanResults = ValueNotifier([]);


    UniversalBle.onAvailabilityChange = (availabilityState) {
      state.value = availabilityState;
    };

    // Set a scan result handler
    UniversalBle.onScanResult = (scanResult) {
      var currentValues = bleScanResults.value;
      final i = currentValues.indexWhere(
            (item) => item.deviceId == scanResult.deviceId,
      );
      if (i < 0) {
        bleScanResults.value = [...currentValues, scanResult];
      } else {
        currentValues[i] = scanResult;
        bleScanResults.value = [...currentValues];
      }
    };

    _initialize();
  }

  void _initialize() async {
    state.value = await UniversalBle.getBluetoothAvailabilityState();
    await startDiscovery();
  }

  Future<void> _performSimModeTasks() async {
    simMode = await Preferences.isSimMode();
    setState(() {});
  }

  Future<void> startDiscovery() async {
    print("start discovery");
    bleScanResults.value = [];
    await UniversalBle.startScan();
    discovering.value = true;
  }

  Future<void> stopDiscovery() async {
    print("stop discovery");
    await UniversalBle.stopScan();
    discovering.value = false;
  }

  Widget _buildListView(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: bleScanResults,
        builder: (context, bleScanResults, child) {
          final items = bleScanResults.where((eventArgs) => eventArgs.name != null).toList();
          return ListView.separated(
            itemBuilder: (context, i) {
              final theme = Theme.of(context);
              final item = items[i];
              final uuid = item.deviceId;
              final rssi = item.rssi;
              final name = item.name;
              return ListTile(
                onTap: () {
                  Navigator.pop(context, BluetoothDeviceData(name ?? 'N/A', null, item));
                },
                title: Text(name ?? 'N/A'),
                subtitle: Text(
                  '$uuid',
                  style: theme.textTheme.bodySmall,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RssiWidget(rssi??0),
                    Text('$rssi'),
                  ],
                ),
              );
            },
            separatorBuilder: (context, i) {
              return const Divider(
                height: 0.0,
              );
            },
            itemCount: items.length,
          );
        },
      ),
    );
  }

  Widget _buildBluetoothStatusMessage(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: state,
      builder: (context, state, child) {
        if (state != AvailabilityState.poweredOn) {
          return Text(
            "Bluetooth state: ${state.name}",
            style: TextStyle(color: Colors.red),
          );
        }
        return const Text("");
      },
    );
  }

  Widget _buildSimButton(BuildContext context) {
    return Builder(
      builder: (context) {
        if (simMode) {
          return OutlinedButton(
              onPressed: () {
                //BluetoothDevice bluetoothDevice = BluetoothDevice.fromId("SIM_MODE");
                return Navigator.pop(context, BluetoothDeviceData("SIM MODE", null, null));
              },
              child: Text("Use Sim Device"));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class RssiWidget extends StatelessWidget {
  final int rssi;

  const RssiWidget(
    this.rssi, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    if (rssi > -70) {
      icon = Icons.wifi_rounded;
    } else if (rssi > -100) {
      icon = Icons.wifi_2_bar_rounded;
    } else {
      icon = Icons.wifi_1_bar_rounded;
    }
    return Icon(icon);
  }
}

class BluetoothDeviceData {
  String deviceName;
  Peripheral? peripheral;
  BleScanResult? bleScanResult;

  BluetoothDeviceData(this.deviceName, this.peripheral, this.bleScanResult);
}
