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

  var logTexts = "".obs;
  late Stream<ConnectionStateUpdate> _currentConnectionStream;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  late QualifiedCharacteristic _txCharacteristic;
  late QualifiedCharacteristic _rxCharacteristic;
  late Stream<List<int>> _receivedDataStream;
  bool _connected = false;
  List<String> _receivedData = [];
  int _numberOfMessagesReceived = 0;


  Uuid xossId = Uuid.parse('00001816-0000-1000-8000-00805f9b34fb');
  String explainText = '상태를 보고싶다면 tap';


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
  void connectDevice(index) {
    stopScanning();

    _currentConnectionStream = flutterReactiveBle.connectToAdvertisingDevice(
      id:deviceDataList.value[index].id,
      prescanDuration: const Duration(seconds: 1),
      withServices: [_UART_UUID, _UART_RX, _UART_TX, xossId],
    );
    logTexts.value = "";
    update();
    _connection = _currentConnectionStream.listen((event) {
      var id = event.deviceId.toString();
      switch(event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            logTexts.value = "${logTexts.value}Connecting to $id\n";
            break;
          }
        case DeviceConnectionState.connected:
          {
            _connected = true;
            logTexts.value = "${logTexts.value}Connected to $id\n";
            _numberOfMessagesReceived = 0;
            _receivedData = [];
            _txCharacteristic = QualifiedCharacteristic(serviceId: _UART_UUID, characteristicId: _UART_TX, deviceId: event.deviceId);
            _receivedDataStream = flutterReactiveBle.subscribeToCharacteristic(_txCharacteristic);
            _receivedDataStream.listen((data) {
              onNewReceivedData(data);
            }, onError: (dynamic error) {
              logTexts.value = "${logTexts.value}Error:$error$id\n";
            });
            _rxCharacteristic = QualifiedCharacteristic(serviceId: _UART_UUID, characteristicId: _UART_RX, deviceId: event.deviceId);
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            _connected = false;
            logTexts.value = "${logTexts.value}Disconnecting from $id\n";
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            logTexts.value = "${logTexts.value}Disconnected from $id\n";
            break;
          }
      }
      update();
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
