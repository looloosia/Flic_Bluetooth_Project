import 'package:flic_bluetooth_project/FlickProvider.dart';
import 'package:flic_bluetooth_project/flicDatabase.dart';
import 'package:flic_bluetooth_project/screen/flic_screen.dart';
import 'package:flic_button/flic_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class FlicsViewScreen extends StatefulWidget {
  const FlicsViewScreen({super.key});

  @override
  State<FlicsViewScreen> createState() => _FlicsViewScreenState();


}

class _FlicsViewScreenState extends State<FlicsViewScreen> {
  FlicButtonPlugin? flicButtonManager;




  @override
  Widget build(BuildContext context) {
    final flickProvider = context.watch<FlickProvider>();

    return GridView.builder(
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
    );
  }




}