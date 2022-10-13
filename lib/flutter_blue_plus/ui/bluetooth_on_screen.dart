import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_screen.dart';
import 'widgets.dart';

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe3e3e3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Flutter Bluetooth tester',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),

      ///main list view
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ///connected device list
            Column(crossAxisAlignment:CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('connected devices'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width-20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: StreamBuilder<List<BluetoothDevice>>(
                      stream: Stream.periodic(const Duration(seconds: 2))
                          .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
                      initialData: const [],
                      builder: (c, snapshot) => Column(
                        children: snapshot.data!
                            .map((d) => ListTile(
                                  title: Text(d.name),
                                  subtitle: Text(d.id.toString()),
                                  trailing: StreamBuilder<BluetoothDeviceState>(
                                    stream: d.state,
                                    initialData: BluetoothDeviceState.disconnected,
                                    builder: (c, snapshot) {
                                      if (snapshot.data ==
                                          BluetoothDeviceState.connected) {
                                        return ElevatedButton(
                                          child: const Text('OPEN'),
                                          onPressed: () => Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DeviceScreen(device: d))),
                                        );
                                      }
                                      return Text(snapshot.data.toString());
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
              stream: FlutterBluePlus.instance.scanResults,
              initialData: const [],
              builder: (c, snapshot) => Column(
                children: snapshot.data!
                    .map(
                      (r) => ScanResultTile(
                        result: r,
                        onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          r.device.connect();
                          return DeviceScreen(device: r.device);
                        })),
                      ),
                    )
                    .toList(),
              ),
            ),

          ],
        ),
      ),

      ///하단부 scan floating button
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              onPressed: () => FlutterBluePlus.instance.stopScan(),
              child:
              const CircularProgressIndicator(
                valueColor:AlwaysStoppedAnimation<Color>(Colors.grey),
              ),

            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () => FlutterBluePlus.instance.startScan(
                        timeout: const Duration(seconds: 4),
                        withServices: [
                          Guid("00001816-0000-1000-8000-00805f9b34fb")
                        ]));
          }
        },
      ),
    );
  }
}


