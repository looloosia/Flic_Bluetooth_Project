import 'package:flic_bluetooth_project/FlickProvider.dart';
import 'package:flic_bluetooth_project/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RadioViewScreen extends StatefulWidget {
  const RadioViewScreen({super.key});

  @override
  State<RadioViewScreen> createState() => _RadioViewScreenState();
}

class _RadioViewScreenState extends State<RadioViewScreen> {
  final ScrollController _scrollController = ScrollController();
  int page = 0;
  final int size = 10;
  List<dynamic> radios = [];
  bool isLoading = false;


  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
        bottom: true,
        child: Column (
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: radios.length,
                itemBuilder: (context, index) {
                  final radio = radios[index];
                  return ListTile(
                    title: Text('${radio['title']}'),
                    onTap: () {
                      String? selectedIp = context.read<FlickProvider>().selectedIp;
                      if (selectedIp != null) {
                        playRadio(selectedIp, radios, index);
                      }
                    },
                  );
                },
              ),
            ),
            if (isLoading)
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(),
                      )
                  )
              )
          ],
        )
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      loadNextPage();
    }
  }

  Future<void> loadFirstPage() async {
    final result = await fetchRadios(0);

    if (result == null) return;
    if (!mounted) return;

    setState(() {
      radios = result;
    });
  }

  Future<void> loadNextPage() async {
    if (isLoading) return;
    page++;

    setState(() {
      isLoading = true;
    });


    final newRadios = await fetchRadios(page);

    if (!mounted) return;

    setState(() {
      if (newRadios != null) {
        radios.addAll(newRadios);
      }
    });

    setState(() {
      isLoading = false;
    });

  }
}
