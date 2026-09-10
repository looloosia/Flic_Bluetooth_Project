import 'package:flic_bluetooth_project/screen/home_screen.dart';
import 'package:flutter/material.dart';


class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreen();
}

class _ConnectScreen extends State<ConnectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(appBarType: AppBarType.finding),
    );
  }
}

