// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/controller.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';

class Screen extends StatelessWidget {
  const Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Controller>(
        init: Controller(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: const Text('Flutter Bluetooth _ tester', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black,),),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          controller.startScanning();
                        },
                        child: const Text('Scan')),
                    TextButton(
                        onPressed: () {
                          controller.stopScanning();
                        },
                        child: const Text('Stop')),
                  ],
                ),


                ///스캔한 데이터 목록 todo: 실시간 업데이트
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.fromLTRB(10,0,10,10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey),
                        borderRadius: const BorderRadius.all(Radius.circular(10))
                      ),
                      height: 200,
                      child: ListView.builder(
                        reverse: true,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.deviceNameList.value.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: (){
                                debugPrint("connecting device");
                                controller.onConnectDevice(index);
                              },
                              child: BlueButton(
                                data: controller.deviceDataList.value[index],
                              ),
                            );
                          }),
                    ),
                  ),
                ),

                ///하단부 state button
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        TextButton(
                            onPressed: () {
                              controller.printState();
                            },
                            child:  Text(controller.explainText)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class BlueButton extends StatelessWidget {
  const BlueButton({Key? key, required this.data}) : super(key: key);

  final DiscoveredDevice data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15,15,0,15),
        width: double.infinity,
        height: 84,
        decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.blueAccent)
        ),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DeviceName : ${data.name}'),
            const SizedBox(height: 7),
            Text('Uuid : ${data.serviceUuids.toString()}'),
          ],
        )),
      ),
    );
  }
}
