import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BlueScreen extends StatefulWidget {
  const BlueScreen({Key? key}) : super(key: key);

  @override
  State<BlueScreen> createState() => _BlueScreenState();
}

class _BlueScreenState extends State<BlueScreen> {

  final FlutterBlue blue = FlutterBlue.instance;

  @override
  void initState() {

    blue.scanResults.listen((results) {
      debugPrint("검색중......");
      debugPrint('result : $results');
      if(results.isNotEmpty){
        setState(() {
          result = results;
        });
      }
    });

    blue.connectedDevices.asStream().listen((List<BluetoothDevice> device) {
      for(BluetoothDevice device in device){
        debugPrint("device : $device");
      }
    });
    super.initState();
  }

   List result =[];
  bool check = false;
  String viewTxt = "대기중...";

  Future blueBtn() async{
    setState(() {
      check = true;
      viewTxt = "검색중...";
    });
    var bl =  await blue.startScan(
        scanMode: ScanMode.balanced,
        allowDuplicates:true,timeout: const Duration(seconds: 12))
        .timeout(const Duration(seconds: 12), onTimeout: () async{
      await blue.stopScan();
      setState(() {
        check = false;
        viewTxt = "ERR";
      });
    });
    debugPrint("startScan : $bl");

    await Future.delayed(const Duration(seconds: 13), () async {
      await blue.stopScan();
      setState(() {
        check = false;
        if(this.result == null) viewTxt = "대기중...";
      });
    });
    return;
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('bluetooth'),),
      body:Column(
        children: [
          TextButton(
            onPressed: blueBtn,
            child: const Text("Blue"),
          ),
          ListView(
            shrinkWrap: true,
            children: [
              Container(height: 500,
                  padding: const EdgeInsets.all(10.0),
                  color: check ? Colors.blue : Colors.red,
                  child: Text(result?.toString()?? viewTxt)
              ),
            ],

          ),
        ],
      ) ,
    );

  }
}
