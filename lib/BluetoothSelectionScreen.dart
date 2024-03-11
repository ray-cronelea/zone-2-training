import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:zone_2_training/preferences.dart';

class BluetoothSelectionScreen extends StatefulWidget {
  const BluetoothSelectionScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BluetoothSelectionScreenState();
}

class _BluetoothSelectionScreenState extends State<BluetoothSelectionScreen> {
  late final ValueNotifier<BluetoothLowEnergyState> state;
  late final ValueNotifier<bool> discovering;
  late final ValueNotifier<List<DiscoveredEventArgs>> discoveredEventArgs;
  late final StreamSubscription stateChangedSubscription;
  late final StreamSubscription discoveredSubscription;

  bool simMode = false;

  @override
  void dispose() {
    super.dispose();
    stateChangedSubscription.cancel();
    discoveredSubscription.cancel();
    state.dispose();
    discovering.dispose();
    discoveredEventArgs.dispose();
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

    state = ValueNotifier(BluetoothLowEnergyState.unknown);
    discovering = ValueNotifier(false);
    discoveredEventArgs = ValueNotifier([]);
    stateChangedSubscription = CentralManager.instance.stateChanged.listen(
      (eventArgs) {
        state.value = eventArgs.state;
      },
    );
    discoveredSubscription = CentralManager.instance.discovered.listen(
      (eventArgs) {
        final items = discoveredEventArgs.value;
        final i = items.indexWhere(
          (item) => item.peripheral == eventArgs.peripheral,
        );
        if (i < 0) {
          discoveredEventArgs.value = [...items, eventArgs];
        } else {
          items[i] = eventArgs;
          discoveredEventArgs.value = [...items];
        }
      },
    );
    _initialize();
  }

  void _initialize() async {
    state.value = await CentralManager.instance.getState();
    await startDiscovery();
  }

  Future<void> _performSimModeTasks() async {
    simMode = await Preferences.isSimMode();
    setState(() {});
  }

  Future<void> startDiscovery() async {
    print("start discovery");
    discoveredEventArgs.value = [];
    await CentralManager.instance.startDiscovery();
    discovering.value = true;
  }

  Future<void> stopDiscovery() async {
    print("stop discovery");
    await CentralManager.instance.stopDiscovery();
    discovering.value = false;
  }

  Widget _buildListView(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: discoveredEventArgs,
        builder: (context, discoveredEventArgs, child) {
          final items = discoveredEventArgs.where((eventArgs) => eventArgs.advertisement.name != null).toList();
          return ListView.separated(
            itemBuilder: (context, i) {
              final theme = Theme.of(context);
              final item = items[i];
              final uuid = item.peripheral.uuid;
              final rssi = item.rssi;
              final advertisement = item.advertisement;
              final name = advertisement.name;
              return ListTile(
                onTap: () {
                  Navigator.pop(context, BluetoothDeviceData(name ?? 'N/A', item.peripheral));
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
                    RssiWidget(rssi),
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
        if (state != BluetoothLowEnergyState.poweredOn) {
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
                return Navigator.pop(context, BluetoothDeviceData("SIM MODE", SimPeripheral()));
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
  Peripheral peripheral;

  BluetoothDeviceData(this.deviceName, this.peripheral);
}

class SimPeripheral implements Peripheral {
  @override
  // TODO: implement uuid
  UUID get uuid => UUID([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
}
