import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreenController extends GetxController {
  @override
  Future<void> onInit() async {
    //앱이 시작하면서 로컬에 아이디가 있는지를 확인
    String? id = await readID();

    //앱이 시작하면서 scan 시작
    FlutterBluePlus.instance.startScan(
        timeout: const Duration(seconds: 4),
        withServices: [Guid("00001816-0000-1000-8000-00805f9b34fb")]);
    //스캔한 데이터 저장
    var subscription = FlutterBluePlus.instance.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        //로컬의 아이디가 널이 아니라면 이전에 연결했던 장비가 존재한다면 바로 연결한다.
        if (id != null) {
          if (id == r.device.id.toString()) {
            r.device.connect();
            debugPrint('@@@@@@@@@@@@');
            debugPrint('connect Complete');
            debugPrint('@@@@@@@@@@@@');
          }
        }
      }
    });
    //스캔 종료
    FlutterBluePlus.instance.stopScan();

    super.onInit();
  }

  Future<void> setID(String id) async {
    final local = await SharedPreferences.getInstance();
    local.setString('id', id);
  }

  Future<String?> readID() async {
    final local = await SharedPreferences.getInstance();
    String? id = local.getString('id');
    return id;
  }

  Future<void> deleteID() async {
    final local = await SharedPreferences.getInstance();
    local.remove('id');
  }
}
