import 'package:flic_bluetooth_project/FlickProvider.dart';
import 'package:flic_bluetooth_project/flic.dart';
import 'package:flic_bluetooth_project/screen/home_screen.dart';
import 'package:flic_bluetooth_project/flicDatabase.dart';
import 'package:flutter/material.dart';
import 'package:flic_button/flic_button.dart';
import 'package:provider/provider.dart';

class FlicScreen extends StatefulWidget {
  final int flicIndex;
  final FlicButtonPlugin? flicButtonManager;
  const FlicScreen({super.key, required this.flicIndex, required this.flicButtonManager});

  @override
  State<FlicScreen> createState() => _FlicScreen();
}

class _FlicScreen extends State<FlicScreen> {
  TextEditingController? textEditingController;
  flicDatabase flicDB = flicDatabase.instance;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        appBarType: AppBarType.flicscreen,
        onConnect: () {
          setState(() {
            final uuid = context.read<FlickProvider>().flics[widget.flicIndex].flicbutton.uuid;
            widget.flicButtonManager?.connectButton(uuid);
          });

        },
        onDisconnect: () {
          setState(() {
            print('flicIndex: ${widget.flicIndex}');
            print('provider list length: ${context.read<FlickProvider>().flics.length}');
            final uuid = context.read<FlickProvider>().flics[widget.flicIndex].flicbutton.uuid;
            widget.flicButtonManager?.disconnectButton(uuid);
            widget.flicButtonManager!.forgetButton(uuid);
            context.read<FlickProvider>().removeFlic(widget.flicIndex);
            Navigator.of(context).pop();
          });
        },),
      body: Column(
        children: [
          Center(
            child: Text('My Flic')
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ClickType.values.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: InkWell(
                    child: Card(
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Image.asset(
                              'asset/${ClickType.values[index].toString().substring('ClickType.'.length)}.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Text('${ClickType.values[index].toString().substring('ClickType.'.length)}')
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      return showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('추가할 기능을 입력하세요.'),
                            content: TextField(
                              controller: textEditingController,
                            ),
                            actions: [
                              Row(
                                children: [
                                  TextButton(
                                    child: Text('취소'),
                                    onPressed: () {
                                      textEditingController!.text = '';
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('추가'),
                                    onPressed: () async {
                                      String uuid = context.read<FlickProvider>().flics[widget.flicIndex].uuid;
                                      await flicDB.updateFlicAction(uuid, ClickType.values[index], textEditingController!.text);
                                      context.read<FlickProvider>().editFlicAction(widget.flicIndex, ClickType.values[index],
                                          textEditingController!.text);
                                      setState(() {

                                        textEditingController!.clear();

                                      });
                                      if (!mounted) return;
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              )

                            ],
                          );
                        }
                      );
                    }
                  )
                );
              },
            ),
          )

        ],
      )
    );
  }
}