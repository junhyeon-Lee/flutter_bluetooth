import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:location_permissions/location_permissions.dart';


Uuid _UART_UUID = Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid _UART_RX   = Uuid.parse("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid _UART_TX   = Uuid.parse("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

class Controller extends GetxController {
  final flutterReactiveBle = FlutterReactiveBle();

  var deviceName = ''.obs;
  RxList deviceNameList = [].obs;
  RxList deviceDataList = [].obs;
  bool isOverLab = false;
  late DiscoveredDevice data;

  StreamSubscription? subscription;
  late Stream<ConnectionStateUpdate> currentConnectionStream;
  late StreamSubscription<ConnectionStateUpdate> connection;

  Uuid xossId = Uuid.parse('00001816-0000-1000-8000-00805f9b34fb');
  String explainText = '상태를 보고싶다면 tap';
  bool connected = false;
  String logTexts = "";

  int _numberOfMessagesReceived = 0;
  late QualifiedCharacteristic _txCharacteristic;
  late QualifiedCharacteristic _rxCharacteristic;
  late Stream<List<int>> _receivedDataStream;
  List<String> _receivedData = [];

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
        //  debugPrint('scanning@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

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
  void connectDevice(int index) {
    stopScanning();

    connection=flutterReactiveBle.connectToDevice(
      id: deviceDataList.value[index].id,
     // servicesWithCharacteristicsToDiscover: {serviceId: [char1, char2]},
      connectionTimeout: const Duration(seconds: 2),
    ).listen((connectionState) {
      debugPrint("success");
    }, onError: (Object error) {
      debugPrint(error.toString());
    });

  }


  void onNewReceivedData(List<int> data) {
    _numberOfMessagesReceived += 1;
    _receivedData.add( "$_numberOfMessagesReceived: ${String.fromCharCodes(data)}");
    if (_receivedData.length > 5) {
      _receivedData.removeAt(0);
    }
    update();
  }

  void onConnectDevice(index) {
    currentConnectionStream = flutterReactiveBle.connectToAdvertisingDevice(
      id:deviceDataList.value[index].id,
      prescanDuration: const Duration(seconds: 1),
      withServices: [xossId],
    );
    logTexts = "";
    update();
    connection = currentConnectionStream.listen((event) {
      var id = event.deviceId.toString();
      switch(event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            logTexts = "${logTexts}Connecting to $id\n";
            break;
          }
        case DeviceConnectionState.connected:
          {
            connected = true;
            logTexts = "${logTexts}Connected to $id\n";
            _numberOfMessagesReceived = 0;
            _receivedData = [];
            _txCharacteristic = QualifiedCharacteristic(serviceId: _UART_UUID, characteristicId: _UART_TX, deviceId: event.deviceId);
            _receivedDataStream = flutterReactiveBle.subscribeToCharacteristic(_txCharacteristic);
            _receivedDataStream.listen((data) {
              onNewReceivedData(data);
            }, onError: (dynamic error) {
              logTexts = "${logTexts}Error:$error$id\n";
            });
            _rxCharacteristic = QualifiedCharacteristic(serviceId: _UART_UUID, characteristicId: _UART_RX, deviceId: event.deviceId);
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            connected = false;
            logTexts = "${logTexts}Disconnecting from $id\n";
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            logTexts = "${logTexts}Disconnected from $id\n";
            break;
          }
      }
      update();
    });
  }


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


