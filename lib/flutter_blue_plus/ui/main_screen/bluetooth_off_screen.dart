import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('블루투스가 꺼져있습니다.\n\n 블루투스를 켜주세요.'),
      ),
    );
  }
}