import 'dart:io';

import 'package:hq_picker/hq_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<HQPickerTelegramMediaPickersState> _sheetKey = GlobalKey();

  List<File>? imageFiles = [];
  List<AssetEntity> selectedAssetList = [];

  void convertToFileList() async {
    List<File>? files = [];

    for (var asset in selectedAssetList) {
      final file = await asset.file; // Convert AssetEntity to File
      if (file != null) {
        files.add(file);
      }
    }
    setState(() {
      imageFiles = files; // Update the state with the list of files
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Open and close HQPickerTelegramMediaPickers
                _sheetKey.currentState?.toggleSheet(context);
                setState(() {});
              },
              child: const Text("Telegram Pickers"),
            ),
          ),

          // HQPickerTelegramMediaPickers widget
          HQPickerTelegramMediaPickers(
            key: _sheetKey,
            requestType: HQPickerRequestType
                .all, // Set to 'all' to display all media types
            maxCountPickMedia: 5,
            maxCountPickFiles: 5,
            primeryColor: Colors.green,
            isRealCameraView: false,
            onMediaPicked: (assets, files) {
              // Update the selectedAssetList
              if (assets != null) {
                selectedAssetList = assets;
                convertToFileList(); // Convert selected assets to files
              }

              if (files != null) {
                for (var file in files) {
                  debugPrint(file.path); // Print the path of selected files
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
