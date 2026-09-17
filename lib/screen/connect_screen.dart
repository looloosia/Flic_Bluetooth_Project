import 'package:flic_bluetooth_project/screen/home_screen.dart';
import 'package:flutter/material.dart';


class ConnectScreen extends StatefulWidget {
  final VoidCallback onStartScan;

  const ConnectScreen({super.key, required this.onStartScan});

  @override
  State<ConnectScreen> createState() => _ConnectScreen();
}

class _ConnectScreen extends State<ConnectScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      widget.onStartScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(appBarType: AppBarType.finding),
    );
  }
}

