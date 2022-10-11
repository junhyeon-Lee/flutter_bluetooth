import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/BlueScreen.dart';
import 'package:flutter_bluetooth/screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Screen(),
    );
  }
}
