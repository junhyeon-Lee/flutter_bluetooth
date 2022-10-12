import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:location_permissions/location_permissions.dart';

class Controller extends GetxController {
  final flutterReactiveBle = FlutterReactiveBle();

  var deviceName = ''.obs;
  RxList deviceNameList = [].obs;
  RxList deviceDataList = [].obs;
  bool isOverLab = false;
  late DiscoveredDevice data;

  StreamSubscription? subscription;

  Uuid xossId = Uuid.parse('00001816-0000-1000-8000-00805f9b34fb');
  String explainText = '상태를 보고싶다면 상단의 state tap';


  ///블루투스 장비들을 스캔
  Future<void> startScanning() async {
    //스캔을 시작하기 전 데이터 리스트를 비워준다.
    deviceNameList.clear();
    deviceDataList.clear();
    //블루투스 권한을 먼저 받고 (비동기)
    await LocationPermissions().requestPermissions();

    subscription = flutterReactiveBle
        .scanForDevices(withServices: [xossId])
        .where((event) => event.name.isNotEmpty)
        .listen((device) {
          data = device;
          debugPrint('scanning@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

          if (deviceNameList.value.isEmpty) {
            if (device.name.isNotEmpty) {
              deviceNameList.add(device.name);
              deviceDataList.add(device);
            }
          } else {
            for (int i = 0; i < deviceNameList.value.length; i++) {
              if (device.name == deviceNameList.value[i]) {
                isOverLab = true;
                break;
              }
            }

            isOverLab ? null : deviceNameList.add(device.name);
            isOverLab ? null : deviceDataList.add(device);
            isOverLab = false;
          }
        }, onError: (e) {
          debugPrint('error@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
          debugPrint(e.toString());
        });
  }

  /// 스캔 종료
  void stopScanning() {
    subscription?.cancel();
    subscription = null;
  }

  ///블루투스 장비와 연결
  void connectDevice() {}

  ///기기의 현재 블루투스 상태를 표시 연결이 가능한지
  void printState() {
    debugPrint(flutterReactiveBle.status.name);

    flutterReactiveBle.statusStream.listen((status) {
      switch (status) {
        case BleStatus.poweredOff:
          explainText = "블루투스가 꺼져있습니다.";
          update();
          break;
        case BleStatus.unsupported:
          explainText = "블루투스 지원되지 않음.";
          update();
          break;
        case BleStatus.ready:
          explainText = "블루투스 준비완료";
          update();
          break;
      }
    });
  }
}
