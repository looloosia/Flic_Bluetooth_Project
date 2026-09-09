import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        },
      ),
    );
  }
}