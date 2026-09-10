import 'dart:ffi';
import 'package:flic_bluetooth_project/screen/connect_screen.dart';
import 'package:flic_bluetooth_project/screen/flic_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flic_button/flic_button.dart';
import 'package:snackbar/snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with Flic2Listener {
  // List<BluetoothDevice> connectedFlics = [];
  // BluetoothDevice? foundDevice;
  FlicButtonPlugin? flicButtonManager;
  List<Flic2Button> connectedFlics = [];

  @override
  void initState() {
    super.initState();
    initFlicPlugin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('임시앱바')
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        padding: const EdgeInsets.all(16.0),
        itemCount: connectedFlics.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // flic 기능들 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FlicScreen(device: connectedFlics[index]),
                )
              );
            },
            child: Column(
              children: [
                Card(
                    child: Text('Flic: ${connectedFlics[index].name}')
                ),
              ],
            )
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Add Flic to Phone'),
        icon: Icon(Icons.add_circle),
        onPressed: () {
          //블루투스 연결 화면으로 이동
          startScanFlic();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConnectScreen(),
            ),
          );
        },
      ),
    );
  }

  void initFlicPlugin() async {
    await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    setState(() {
      flicButtonManager = FlicButtonPlugin(flic2listener: this);
    });

    await Future.delayed(Duration(milliseconds: 500));

    final buttons = await flicButtonManager!.getFlic2Buttons();
    if (buttons.isNotEmpty){
      print('이미 있는 버튼을 불러오기');

      for (var button in buttons) {
        flicButtonManager!.forgetButton(button.uuid);
      }
    }
  }

  void startScanFlic() {
    flicButtonManager?.scanForFlic2();
  }

  @override
  void onButtonFound(Flic2Button button) async {
    super.onButtonFound(button);
    print('--------버튼 found');

    final result =
        await flicButtonManager?.listenToFlic2Button(button.uuid);
    print('listen result: $result');
    setState(() {
      connectedFlics.add(button);
    });

    Navigator.pop(context);
  }

  @override
  void onButtonDiscovered(String buttonAddress) {
    super.onButtonDiscovered(buttonAddress);
    print('Flic 기기 발견');
  }

  @override
  void onButtonConnected()
  {
    super.onButtonConnected();
    print('버튼 연결됨');
  }
  @override
  void onButtonClicked(Flic2ButtonClick buttonClick) {
    print('-----button clicked');
    String? clickCount = '';
    if (buttonClick.isSingleClick) {
      clickCount = '1';
    }
    else if (buttonClick.isDoubleClick) {
      clickCount = '2';
    }
    else if (buttonClick.isHold) {
      clickCount = '길게누름';
    } else {
      clickCount = '0';
    }
    var snackBar = SnackBar(
        content: Text('${clickCount} 번 클릭'),
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Flic 장치 스캔
  // void startScan() {
  //   print('startscan');
  //   requestPermissions();
  //   FlutterBluePlus.startScan(timeout: Duration(seconds: 30));
  //
  //   FlutterBluePlus.scanResults.listen((results) async {
  //     for (ScanResult result in results) {
  //       print('-----------device found: ${result.device.name}');
  //
  //       if (result.device.name.contains('Flic')) {
  //         foundDevice = result.device;
  //         FlutterBluePlus.stopScan();
  //         await connectToDevice(result.device);
  //         discoverServices(result.device);
  //
  //         if (mounted) {
  //           // Navigator.pop(context);
  //         }
  //         return;
  //       }
  //     }
  //   });
  // }
  //
  // // 장치 연결
  // Future<void> connectToDevice(BluetoothDevice device) async {
  //   await device.connect(
  //     license: License.nonprofit,
  //   );
  //   setState(() {
  //     if (!connectedFlics.contains(device))
  //       connectedFlics.add(device);
  //   });
  //   print('---------Connected to ${device.name}');
  //   print('---------${connectedFlics.length}');
  // }
  //
  // void disconnectFromDevice(BluetoothDevice device) async {
  //   await device.disconnect();
  //   print('Disconnected from ${device.name}');
  // }
  //
  // // 권한 요청
  // void requestPermissions() async {
  //   if (await Permission.location.request().isGranted) {
  //     print('----------location permission granted');
  //   }
  // }
  //
  // void discoverServices(BluetoothDevice device) async {
  //   List<BluetoothService> services = await device.discoverServices();
  //   for (BluetoothService service in services) {
  //     print('Service: ${service.uuid}');
  //     if (service.uuid.toString() == '00420000-8f59-4420-870d-84f3b617e493') {
  //       for (BluetoothCharacteristic characteristic in service.characteristics) {
  //         if (characteristic.uuid.toString() == '00420002-8f59-4420-870d-84f3b617e493') {
  //           print('-----------flic 버튼 찾음');
  //           enableNotifications(characteristic);
  //         }
  //       }
  //     }
  //   }
  // }
  //
  // void enableNotifications(BluetoothCharacteristic characteristic) async {
  //   await characteristic.setNotifyValue(true);
  //   characteristic.value.listen((data) {
  //     print('------Notification received: $data');
  //   });
  // }
}