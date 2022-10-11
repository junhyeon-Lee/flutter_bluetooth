import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:location_permissions/location_permissions.dart';

class Controller extends GetxController {
  final flutterReactiveBle = FlutterReactiveBle();

  var deviceName = ''.obs;
  var deviceNameList = [].obs;

  Future<void> startScanning() async {
    //블루투스 권한을 먼저 받고 (비동기)
    await LocationPermissions().requestPermissions();

    flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
      debugPrint('scanning@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
      debugPrint(device.name);
      debugPrint(device.id);
      debugPrint(device.rssi.toString());
      if (device.name.isNotEmpty) {
        deviceNameList.add(device.name);
        deviceName.value = device.name;
      }
    }, onError: (e) {
      debugPrint('error@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
      debugPrint(e.toString());
    });
  }

  void printState() {
    debugPrint('tap');
    debugPrint(flutterReactiveBle.status.name);

    flutterReactiveBle.statusStream.listen((status) {
      switch (status) {
        case BleStatus.poweredOff:
          debugPrint("블루투스가 꺼져있습니다.");
          break;
        case BleStatus.unsupported:
          debugPrint("블루투스 지원되지 않음.");
          break;
        case BleStatus.ready:
          debugPrint("블루투스가 준비완료.");
          break;
      }
    });
  }
}
