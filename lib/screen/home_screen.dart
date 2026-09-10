import 'package:flic_bluetooth_project/FlickProvider.dart';
import 'package:flic_bluetooth_project/flic.dart';
import 'package:flic_bluetooth_project/screen/connect_screen.dart';
import 'package:flic_bluetooth_project/screen/flic_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flic_button/flic_button.dart';
import 'package:snackbar/snackbar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with Flic2Listener {
  // List<BluetoothDevice> connectedFlics = [];
  // BluetoothDevice? foundDevice;
  FlicButtonPlugin? flicButtonManager;
  // List<Flic2Button> connectedFlics = [];

  @override
  void initState() {
    super.initState();
    initFlicPlugin();
  }

  @override
  Widget build(BuildContext context) {
    final flickProvider = context.watch<FlickProvider>();

    return Scaffold(
      appBar: CommonAppBar(
        appBarType: AppBarType.home,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        padding: const EdgeInsets.all(16.0),
        itemCount: flickProvider.flics.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // flic 기능들 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FlicScreen(flicIndex: index, flicButtonManager: flicButtonManager,),
                )
              );
            },
            child: Column(
              children: [
                Image.asset(
                  'asset/flic_icon.png',
                  width: 120,
                  height: 120,
                ),
                Text('My Flic $index'),
              ],
            )
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Row(
          children: [
            Text('Add Flic to Phone'),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.add_circle,
                size: 30,
              ),
            )
          ],
        ),
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
      context.read<FlickProvider>().addFlic(button);
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
    ClickType clickType;
    if (buttonClick.isSingleClick) {
      clickType = ClickType.pushAction;
    }
    else if (buttonClick.isDoubleClick) {
      clickType = ClickType.doublePushAction;
    }
    else if (buttonClick.isHold) {
      clickType = ClickType.holdAction;
    } else {
      clickType = ClickType.pushAction;
    }
    var snackBar = SnackBar(
        content: Text('<${context.read<FlickProvider>().getFlickAction(buttonClick.button.uuid, clickType)}> 기능 실행'),
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget{
  final AppBarType appBarType;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  const CommonAppBar({
    super.key,
    required this.appBarType,
    this.onConnect,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: appBarType == AppBarType.home ? Image.asset(
          'asset/logo.png',
          height: 36,
        ) : appBarType == AppBarType.finding ? Center(
          child: Text('Press and hold')
        ): null,
        actions:
        getAppBarActions(appBarType, context, onConnect, onDisconnect)
    );

  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

enum AppBarType {
  home, finding, flicscreen
}

List<Widget> getAppBarActions(AppBarType type, BuildContext context, VoidCallback? onConnect, VoidCallback? onDisconnect) {
  switch (type) {
    case AppBarType.home:
      return [
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {},
        )
      ];
    case AppBarType.finding:
      return [];
    case AppBarType.flicscreen:
      return [
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: ListView(
                        padding: const EdgeInsets.all(8),
                        children: [
                          ListTile(
                            title: Center(
                                child: TextButton(
                                    child: Text('connect'),
                                  onPressed: () {
                                      onConnect?.call();
                                      Navigator.of(context).pop();
                                  },
                                )
                            )
                          ),
                          ListTile(
                            title: Center(
                                child: TextButton(
                                  child: Text('disconnect'),
                                  onPressed: () {
                                    onDisconnect?.call();
                                    Navigator.of(context).pop();
                                  },
                                )
                            )
                          )
                        ],
                      )
                    )
                  );
                }
            );
          },
        )
      ];
    default:
      return [];
  }
}