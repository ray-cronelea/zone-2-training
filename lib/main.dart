import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'MyApp.dart';

void main() {
  var themeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    ),
  );

  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    [Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan].request().then((status) {
      runApp(MaterialApp(
        theme: themeData,
        home: const MyApp(),
      ));
    });
  } else {
    runApp(MaterialApp(
      theme: themeData,
      home: const MyApp(),
    ));
  }
}