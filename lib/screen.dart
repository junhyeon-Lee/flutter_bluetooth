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
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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

                Obx(
                  ()=> SizedBox(height: 600,
                    child: ListView.builder(
                      shrinkWrap: true,
                        itemCount: controller.deviceNameList.value.length,
                        itemBuilder: (BuildContext context, int index){
                      return  BlueButton(data: controller.deviceDataList.value[index],);
                    }),
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
      padding: const EdgeInsets.fromLTRB(15,15,15,0),
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: const BorderRadius.all(Radius.circular(10))
        ),
        child: Center(child: Text(data.name)),
      ),

    );
  }
}

