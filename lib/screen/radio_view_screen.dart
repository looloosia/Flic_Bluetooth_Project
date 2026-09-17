import 'package:flic_bluetooth_project/api_service.dart';
import 'package:flutter/material.dart';

class RadioViewScreen extends StatefulWidget {
  const RadioViewScreen({super.key});

  @override
  State<RadioViewScreen> createState() => _RadioViewScreenState();
}

class _RadioViewScreenState extends State<RadioViewScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchRadios(),
        builder: (context, snapshot) {
          return ListView.builder(
          itemCount: snapshot.data != null ? snapshot.data!.length
                      : 0,
          itemBuilder: (context, index) {
            final radio = snapshot.data![index];
            return ListTile(
              title: Text('${radio['title']}'),
              onTap: () {},
            );
          },
        );
        }
    );
  }
}
