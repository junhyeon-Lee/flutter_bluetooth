import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppbar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Bluetooth for Cycling Sensor',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FlutterBluePlus.instance.startScan(
                  timeout: const Duration(seconds: 4),
                  withServices: [Guid("00001816-0000-1000-8000-00805f9b34fb")]);
            },
            icon: const Icon(
              Icons.sensors,
              color: Colors.black,
            ),
          ),
        ]);
  }

  @override
  Size get preferredSize => const Size.fromHeight(58);
}
