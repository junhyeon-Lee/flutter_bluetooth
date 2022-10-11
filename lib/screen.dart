import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/controller.dart';
import 'package:get/get.dart';

class Screen extends StatelessWidget {
  const Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Controller>(
        init: Controller(),
        builder: (controller) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          controller.startScanning();
                        },
                        child: const Text('Scan')),
                    TextButton(
                        onPressed: () {
                          controller.printState();
                        },
                        child: const Text('State')),
                  ],
                ),
                Container(
                  color: Colors.greenAccent,
                  width: Get.width,
                  height: Get.height * 0.7,
                  child: Obx(() => Text(controller.deviceNameList.value.toString())),
                ),
              ],
            ),
          );
        });
  }
}
