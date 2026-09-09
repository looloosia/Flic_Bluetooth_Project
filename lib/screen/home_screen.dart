import 'package:flic_bluetooth_project/screen/connect_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BluetoothDevice? foundDevice;

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
        itemCount: 1,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // flic 기능들 화면으로 이동
              print('tap');
            },
            child: Column(
              children: [
                Card(
                    child: Text('My Flic')
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
          startScan();
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

  // Flic 장치 스캔
  void startScan() {
    requestPermissions();
    FlutterBluePlus.startScan(timeout: Duration(seconds: 30));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        print('-----------device found: ${result.device.name}');

        if (result.device.name.contains('Flic')) {
          foundDevice = result.device;
          FlutterBluePlus.stopScan();
          connectToDevice(result.device);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            )
          );
        }
      }
    });
  }

  // 장치 연결
  void connectToDevice(BluetoothDevice device) async {
    await device.connect(
      license: License.nonprofit,
    );
    print('---------Connected to ${device.name}');
  }

  void disconnectFromDevice(BluetoothDevice device) async {
    await device.disconnect();
    print('Disconnected from ${device.name}');
  }

  // 권한 요청
  void requestPermissions() async {
    if (await Permission.location.request().isGranted) {
      print('----------location permission granted');
    }
  }
}