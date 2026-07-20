import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hq_picker/hq_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HQPicker Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'HQPicker Comprehensive Example'),
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
  final GlobalKey<HQPickerTelegramMediaPickersState> _telegramSheetKey =
      GlobalKey();

  List<HQPickerResult> selectedResults = [];
  List<AssetEntity> telegramAssets = [];
  List<FileSystemEntity> telegramFiles = [];

  void _updateResults(List<HQPickerResult> results) {
    setState(() {
      selectedResults = results;
    });
  }

  // Use Case 1: Custom Picker with Cropping and Compressing
  void _openCustomPickerWithCrop() async {
    final results = await HQPicker.customPicker(
      context: context,
      maxCount: 5,
      requestType: HQPickerRequestType.image,
      config: const HQPickerConfig(
        enableCropping: true,
        compressImage: true,
        compressQuality: 70,
        localizations: HQPickerLocalizations.en(),
        theme: HQPickerTheme(
          appbarColor: Colors.deepPurple,
          confirmButtonColor: Colors.deepPurple,
          indicatorColor: Colors.deepPurple,
        ),
      ),
    );
    _updateResults(results);
  }

  // Use Case 2: Bottom Sheet Picker for Videos
  void _openBottomSheetForVideos() async {
    final results = await HQPicker.bottomSheets(
      context: context,
      maxCount: 3,
      requestType: HQPickerRequestType.video,
      config: const HQPickerConfig(enableCropping: false, compressImage: false),
    );
    _updateResults(results);
  }

  // Use Case 3: Instagram Style Picker
  void _openInstagramPicker() async {
    final picker = const HQPicker(
      maxCount: 5,
      requestType: HQPickerRequestType.image,
      config: HQPickerConfig(enableCropping: true, compressImage: true),
    );

    final results = await picker.instagram(context);
    _updateResults(results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Select a Use Case:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.crop),
              label: const Text("Custom Picker (Images + Crop + Compress)"),
              onPressed: _openCustomPickerWithCrop,
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              icon: const Icon(Icons.video_collection),
              label: const Text("Bottom Sheet (Videos Only)"),
              onPressed: _openBottomSheetForVideos,
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Instagram Style Picker"),
              onPressed: _openInstagramPicker,
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Telegram Media Pickers (Widget)"),
              onPressed: () {
                _telegramSheetKey.currentState?.toggleSheet(context);
              },
            ),
            const SizedBox(height: 20),

            // Display Telegram Pickers inline (hidden until toggled)
            HQPickerTelegramMediaPickers(
              key: _telegramSheetKey,
              requestType: HQPickerRequestType.all,
              maxCountPickMedia: 5,
              maxCountPickFiles: 5,
              primeryColor: Colors.deepPurple,
              isRealCameraView: false,
              onMediaPicked: (assets, files) {
                setState(() {
                  telegramAssets = assets ?? [];
                  telegramFiles = files?.cast<FileSystemEntity>() ?? [];
                });
              },
            ),

            const Divider(thickness: 2),
            const Text(
              "Selected Results:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Show selected results from main pickers
            if (selectedResults.isNotEmpty)
              ...selectedResults.map((result) {
                final hasFile = result.file != null;
                return ListTile(
                  leading: hasFile
                      ? Image.file(
                          result.file!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image),
                  title: Text(hasFile ? "Processed Image" : "Raw Asset"),
                  subtitle: Text("ID: ${result.asset.id}"),
                );
              }),

            // Show selected results from Telegram picker (Assets)
            if (telegramAssets.isNotEmpty)
              ...telegramAssets.map((asset) {
                return ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Telegram Asset"),
                  subtitle: Text("Type: ${asset.type}"),
                );
              }),

            // Show selected results from Telegram picker (Files/Audio)
            if (telegramFiles.isNotEmpty)
              ...telegramFiles.map((file) {
                return ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: const Text("Telegram File"),
                  subtitle: Text(file.path.split('/').last),
                );
              }),
          ],
        ),
      ),
    );
  }
}
