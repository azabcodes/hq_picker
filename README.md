# HQPicker

A high-performance, fully customizable, and multi-mode media picker for Flutter, entirely powered by the **BLoC pattern**. HQPicker ensures 60fps scrolling, zero `setState` sluggishness, and elegant memory management even with thousands of media files.

## ✨ Features

- **BLoC Architecture**: Zero `setState` inside the core picker! Optimized for fast rebuilds and scalability.
- **Pagination Built-in**: Lazy-loads images/videos in chunks of 60 to prevent memory leaks and freezing.
- **Multiple UI Modes**:
  - 📸 **Instagram Style**: Full-page preview with grid selection.
  - 💬 **Telegram Style**: Dragable bottom sheet with tabs for Media, Audio, and Files.
  - 📑 **Custom Picker / Scaffold Bottom Sheet**: Highly customizable simple pickers.
- **File System Support**: Natively fetches and filters Audio (`.mp3`, `.wav`, etc.) and general Files from the device.
- **Cropping & Compression**: Built-in support for editing images before returning them.
- **Localization**: Supports multiple languages (English, Arabic, etc.) via Dependency Injection.

---

## 🚀 Getting Started

You can install the package directly from your terminal:
```bash
flutter pub add hq_picker
```

Or add it manually to your `pubspec.yaml`:
```yaml
dependencies:
  hq_picker: ^1.0.0
```

Import it in your Dart code:
```dart
import 'package:hq_picker/hq_picker.dart';
```

---

## 📱 Usage Examples

### 1. Telegram Media Picker (The Ultimate Picker)

The Telegram picker is an inline widget that provides a `DraggableScrollableSheet` with tabs for Gallery, Files, and Audio. It uses a `GlobalKey` to toggle the sheet.

```dart
final GlobalKey<HQPickerTelegramMediaPickersState> _telegramSheetKey = GlobalKey();

// Open the picker
ElevatedButton(
  onPressed: () {
    _telegramSheetKey.currentState?.toggleSheet(context);
  },
  child: const Text("Open Telegram Pickers"),
),

// Place this widget in your Widget tree (usually inside a Stack or at the bottom of a Column)
HQPickerTelegramMediaPickers(
  key: _telegramSheetKey,
  requestType: HQPickerRequestType.all, // Shows Images, Videos, Audio, and Files
  maxCountPickMedia: 5,
  maxCountPickFiles: 5,
  primeryColor: Colors.deepPurple,
  onMediaPicked: (assets, files) {
    if (assets != null) {
      print("Picked ${assets.length} images/videos");
    }
    if (files != null) {
      print("Picked ${files.length} device files");
    }
  },
),
```

### 2. Instagram Style Picker

A full-screen picker where the selected image is previewed at the top, and the gallery grid is displayed at the bottom.

```dart
ElevatedButton(
  onPressed: () async {
    final picker = HQPicker(
      maxCount: 5,
      requestType: HQPickerRequestType.image,
      config: const HQPickerConfig(
        enableCropping: true, 
        compressImage: true
      ),
    );

    // Returns a List<HQPickerResult>
    final results = await picker.instagram(context);
    
    if (results.isNotEmpty) {
      print("Picked ${results.length} images");
      // You can access the raw AssetEntity or the processed File:
      // final File? processedImage = results.first.file;
      // final AssetEntity originalAsset = results.first.asset;
    }
  },
  child: const Text("Open Instagram Picker"),
)
```

### 3. Custom Bottom Sheet Picker

A standard bottom sheet picker tailored for specific configurations like video-only selection.

```dart
ElevatedButton(
  onPressed: () async {
    final results = await HQPicker.bottomSheets(
      context: context,
      maxCount: 3,
      requestType: HQPickerRequestType.video, // Videos only
      config: const HQPickerConfig(
        enableCropping: false,
        compressImage: false,
      ),
    );
    
    if (results.isNotEmpty) {
      print("Picked ${results.length} videos");
    }
  },
  child: const Text("BottomSheet (Videos)"),
)
```

---

## ⚙️ Configuration & Localization

You can easily theme and localize the picker by passing an `HQPickerConfig` object to any of the pickers:

```dart
final results = await HQPicker.scaffoldBottomSheet(
  context: context,
  maxCount: 10,
  requestType: HQPickerRequestType.all,
  config: const HQPickerConfig(
    localizations: HQPickerLocalizations.ar(), // Arabic Localization
    theme: HQPickerTheme(
      appbarColor: Colors.deepPurple,
      confirmButtonColor: Colors.deepPurple,
    ),
  ),
);
```

---

## 📝 Return Types

- **`HQPickerTelegramMediaPickers`** returns raw `List<AssetEntity>` (for gallery) and `List<File>` (for device files) via the `onMediaPicked` callback.
- **Other Pickers (`instagram`, `customPicker`, `bottomSheets`)** return a `List<HQPickerResult>`. This result contains:
  - `asset`: The original `AssetEntity`.
  - `file`: The processed `File?` (if cropping or compression was enabled).

