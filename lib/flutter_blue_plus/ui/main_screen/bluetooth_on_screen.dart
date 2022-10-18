import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/flutter_blue_plus/controller/controller.dart';
import 'package:flutter_bluetooth/flutter_blue_plus/ui/main_screen/main_screen_widget/main_appbar.dart';
import 'package:get/get.dart';
import '../device_screen/device_screen.dart';
import 'main_screen_widget/scan_result.dart';

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainScreenController>(
        init: MainScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: const Color(0xffe3e3e3),
            appBar: const MainAppbar(),

            ///main list view
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ///connected device list
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 20,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: StreamBuilder<List<BluetoothDevice>>(
                            stream: Stream.periodic(const Duration(seconds: 2))
                                .asyncMap((_) =>
                                    FlutterBluePlus.instance.connectedDevices),
                            initialData: const [],
                            builder: (c, snapshot) => Column(
                              children: snapshot.data!
                                  .map((d) => ListTile(
                                        title: Text(d.name),
                                        subtitle: Text(d.id.toString()),
                                        trailing:
                                            StreamBuilder<BluetoothDeviceState>(
                                          stream: d.state,
                                          initialData:
                                              BluetoothDeviceState.disconnected,
                                          builder: (c, snapshot) {
                                            if (snapshot.data ==
                                                BluetoothDeviceState
                                                    .connected) {
                                              return ElevatedButton(
                                                child: const Text('OPEN'),
                                                onPressed: () => Navigator.of(
                                                        context)
                                                    .push(MaterialPageRoute(
                                                        builder: (context) =>
                                                            DeviceScreen(
                                                                device: d))),
                                              );
                                            }
                                            return Text(
                                                snapshot.data.toString());
                                          },
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  ///scanned device list
                  StreamBuilder<List<ScanResult>>(
                    //스캔한 장비들이 나타난다.
                    stream: FlutterBluePlus.instance.scanResults,
                    initialData: const [],
                    builder: (c, snapshot) => Column(
                      children: snapshot.data!
                          .map(
                            (r) => ScanResultTile(
                                result: r,
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    //connect 버튼을 누르면 id를 로컬에 저장한다.
                                    controller.setID(r.device.id.toString());
                                    //디바이스를 연결하고
                                    r.device.connect();
                                    //연결된 디바이스의 상세 페이지로 이동한다.
                                    return DeviceScreen(device: r.device);
                                  }));
                                }),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
