import 'package:flutter/material.dart';
import 'package:flic_button/flic_button.dart';

class FlicScreen extends StatelessWidget {
  final Flic2Button device;

  const FlicScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Center(
            child: Text('My Flic ${device.uuid}')
          ),

        ],
      )
    );
  }
}