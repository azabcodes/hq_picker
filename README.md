# HQPicker

This is a multi-picker package that includes several different modes, making it easy to use.

## Features

- Easy integration.
- Customizable components.
- Performance optimized.
- Extensive documentation.
- Picker Ui Instagram.
- This is a multi-picker.

## Getting started

```yaml
import 'package:hq_picker/hq_picker.dart';
```

```yaml
dependencies:
hq_picker: ^0.0.1
```

## Usage

### Instagram Picker

```dart
  List<AssetEntity> selectedAssetList = [];

  ElevatedButton(
    onPressed: () {
      var picker = const HQPicker(
        maxCount: 5,
        requestType: HQPickerRequestType.image,
      ).instagram(context);
      
      picker.then((value) {
        selectedAssetList = value;
        convertToFileList();
      });
    },
    child: const Text("Instagram picker"),
  ),

```

- OR

```dart
  onPressed: () {
    const HQPicker(
      maxCount: 10, 
      requestType: HQPickerRequestType.image,
    ).instagram(context).then((onValue) {
      setState(() {
        selectedAssetList = onValue;
        convertToFileList();
      });
    });
  },
```

### HQPickerCustomPicker

```dart
  ElevatedButton(
    onPressed: () {
      var picker = const HQPickerCustomPicker(
        maxCount: 5,
        requestType: HQPickerRequestType.image,
      ).getPicAssets(context);
      
      picker.then((value) {
        selectedAssetList = value;
        convertToFileList();
      });
    },
    child: const Text("Custom Picker"),
  )
```

### HQPickerBottomSheets

```dart
  ElevatedButton(
    onPressed: () {
      var picker = HQPicker.bottomSheets(
        context: context,
        maxCount: 5,
        requestType: HQPickerRequestType.image,
      );
      picker.then((value) {
        setState(() {
          selectedAssetList = value;
          convertToFileList(); // تبدیل AssetEntity به فایل‌ها
        });
      });
    },
    child: const Text("BottomSheet"),
  ),
```

### HQPickerTelegramMediaPickers

- Step 1: Create a GlobalKey
  Start by creating a GlobalKey to manage the state of the HQPickerTelegramMediaPickers widget.

```dart
final GlobalKey<HQPickerTelegramMediaPickersState> _sheetKey = GlobalKey();

```

- Step 2: Create a Button to Open the Picker
  Next, create a button that will open the media picker when pressed.

```dart
ElevatedButton(
  onPressed: () {
    // Open the HQPickerTelegramMediaPickers
    _sheetKey.currentState?.toggleSheet(context);
  },
  child: const Text("Open Telegram Pickers"),
),

```

- Step 3: Implement the HQPickerTelegramMediaPickers Widget
  Add the HQPickerTelegramMediaPickers widget to your widget tree. It's important to set the requestType to a general value (like HQPickerRequestType.all) to ensure that all types of media (images, videos, files) are displayed. Avoid changing this to a more specific type if you want the user to have access to all media options.

```dart
  HQPickerTelegramMediaPickers(
    key: _sheetKey,
    requestType: HQPickerRequestType.all, // Set to 'all' to display images, videos, and files
    maxCountPickMedia: 5, // Maximum number of media that can be selected
    primeryColor: Colors.green, // Primary color for the UI
    isRealCameraView: false, // Set to true to use the real camera view
    onMediaPicked: (assets, files) {
      if (files != null) {
        for (var file in files) {
          debugPrint(file.path); // Print the path of selected files
        }
      } else if (assets != null) {
        for (var asset in assets) {
          debugPrint("Asset: ${asset.file}"); // Print the asset details
        }
      }
    },
  ),
```

- Complete Example
  Here's a complete example of how to implement the HQPickerTelegramMediaPickers in your Flutter app. This example shows how to select media files, convert them to a list of File, and prepare them for database storage.

```dart
import 'package:flutter/material.dart';
import 'package:telegram_media_pickers/telegram_media_pickers.dart';

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
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
            requestType: HQPickerRequestType.all, // Set to 'all' to display all media types
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
          )
        ],
      ),
    );
  }
}
```

### HQPickerScaffoldBottomSheet

```dart
  ElevatedButton(
    onPressed: () async {
      await HQPicker.scaffoldBottomSheet(
        context: context,
        maxCount: 5,
        requestType: HQPickerRequestType.image,
        confirmText: "Confirm",
        textEmptyList: "No album found",
        confirmButtonColor: Colors.blue,
        confirmTextColor: Colors.white,
        backgroundColor: Colors.white,
        textEmptyListColor: Colors.grey,
        backgroundSnackBarColor: Colors.red,
      ).then((value) {
        selectedAssetList = value;
        convertToFileList();
      });
    },
    child: const Text("scaffoldBottomSheet"),
  ),
```

### HQPickerBottomSheetImageSelector

```dart

  ElevatedButton(
    onPressed: () async {
      await HQPicker.bottomSheetImageSelector(
        cameraImageSettings: HQPickerCameraImageSettings(),
        context: context,
        maxCount: 5,
        requestType: HQPickerRequestType.image,
        confirmText: "Confirm",
        textEmptyList: "No album found",
        confirmButtonColor: Colors.blue,
        confirmTextColor: Colors.black,
        backgroundColor: Colors.white,
        textEmptyListColor: Colors.grey,
        backgroundSnackBarColor: Colors.red,
      ).then((value) {
        selectedAssetList = value;
        convertToFileList();
      });
    },
    child: const Text("bottomSheetImageSelector"),
  ),
```
