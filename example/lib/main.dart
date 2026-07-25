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
  HQPickerShape selectedShape = HQPickerShape.instagram;

  void _updateResults(List<HQPickerResult> results) {
    setState(() {
      selectedResults = results;
    });
  }

  void _openSelectedShapePicker() async {
    final results = await HQPicker.pick(
      context: context,
      shape: selectedShape,
      maxCount: 5,
      requestType: HQPickerRequestType.all,
      config: const HQPickerConfig(
        enableCropping: true,
        compressImage: true,
        compressQuality: 70,
      ),
    );
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
              "Select Picker Shape / Style:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<HQPickerShape>(
              initialValue: selectedShape,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Picker Shape (HQPickerShape)',
              ),
              items: HQPickerShape.values.map((shape) {
                return DropdownMenuItem(
                  value: shape,
                  child: Text(shape.name),
                );
              }).toList(),
              onChanged: (shape) {
                if (shape != null) {
                  setState(() {
                    selectedShape = shape;
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.touch_app),
              label: Text("Launch ${selectedShape.name.toUpperCase()} Picker"),
              onPressed: _openSelectedShapePicker,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1),

            const Text(
              "Inline Telegram Picker Example:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Toggle Inline Telegram Sheet"),
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
                final file = result.file;
                final asset = result.asset;
                return ListTile(
                  leading: file != null
                      ? Image.file(
                          file,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.insert_drive_file),
                        )
                      : const Icon(Icons.image),
                  title: Text(
                    file != null
                        ? "File: ${file.path.split('/').last}"
                        : "Asset: ${asset?.id}",
                  ),
                  subtitle: Text(
                    asset != null
                        ? "Type: ${asset.type}"
                        : "Path: ${file?.path}",
                  ),
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
