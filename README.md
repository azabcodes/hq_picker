# HQPicker

A high-performance, fully customizable, and multi-mode media picker for Flutter, entirely powered by the **BLoC pattern**. HQPicker ensures 60fps scrolling, zero `setState` sluggishness, and elegant memory management even with thousands of media files.

##  Features

- **BLoC Architecture**: Zero `setState` inside the core picker! Optimized for fast rebuilds and scalability.
- **Unified `HQPickerShape` API**: Choose any UI style/shape (`instagram`, `telegram`, `custom`, `bottomSheet`, `scaffoldBottomSheet`, `bottomSheetImageSelector`, `document`, `directory`) using a single enum!
- **Pagination Built-in**: Lazy-loads images/videos in chunks of 60 to prevent memory leaks and freezing.
- **Multiple UI Shapes & Modes**:
  -  **Instagram Style**: Full-page preview with grid selection.
  -  **Telegram Style**: Draggable bottom sheet with tabs for Media, Audio, and Files.
  -  **Custom Picker / Scaffold Bottom Sheet**: Highly customizable simple pickers.
  -  **Document & Folder Picker**: Native system dialogs for files and directories.
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
  hq_picker: ^0.0.2
```

Import it in your Dart code:
```dart
import 'package:hq_picker/hq_picker.dart';
```

---

## 📱 Usage Examples

### 1. Unified `HQPickerShape` API (Recommended)

You can launch any picker shape using `HQPicker.pick(...)` or `HQPickerFilePicker.pick(...)`:

```dart
// Launch Instagram shape
final results = await HQPicker.pick(
  context: context,
  shape: HQPickerShape.instagram,
  maxCount: 5,
  requestType: HQPickerRequestType.image,
);

// Launch Telegram shape modally
final telegramResults = await HQPicker.pick(
  context: context,
  shape: HQPickerShape.telegram,
  maxCount: 5,
);

// Launch Document picker
final docResults = await HQPicker.pick(
  context: context,
  shape: HQPickerShape.document,
  allowedExtensions: ['pdf', 'docx'],
);
```

### 2. Convenience Helper Methods

`HQPickerFilePicker` and `HQPicker` provide clean convenience methods centered around `HQPickerShape`:

```dart
// Pick Images
final images = await HQPickerFilePicker.pickImage(
  context: context,
  shape: HQPickerShape.instagram,
  maxCount: 5,
);

// Pick Videos
final videos = await HQPickerFilePicker.pickVideo(
  context: context,
  shape: HQPickerShape.custom,
  maxCount: 3,
);

// Pick Documents
final docs = await HQPickerFilePicker.pickDocument(
  shape: HQPickerShape.document,
  allowedExtensions: ['pdf'],
);

// Pick Directory
final dir = await HQPickerFilePicker.pickDirectory();
```

### 3. Inline Telegram Media Sheet

The Telegram picker can also be used inline in your widget tree:

```dart
final GlobalKey<HQPickerTelegramMediaPickersState> _telegramSheetKey = GlobalKey();

// Open the sheet
ElevatedButton(
  onPressed: () {
    _telegramSheetKey.currentState?.toggleSheet(context);
  },
  child: const Text("Open Telegram Sheet"),
);

// Widget in tree
HQPickerTelegramMediaPickers(
  key: _telegramSheetKey,
  requestType: HQPickerRequestType.all,
  maxCountPickMedia: 5,
  maxCountPickFiles: 5,
  primeryColor: Colors.deepPurple,
  onMediaPicked: (assets, files) {
    print("Picked ${assets?.length} assets and ${files?.length} files");
  },
);
```

---

##  Configuration & Localization

You can easily theme and localize the picker by passing an `HQPickerConfig` object:

```dart
final results = await HQPicker.pick(
  context: context,
  shape: HQPickerShape.scaffoldBottomSheet,
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

##  Return Types

All pickers return `List<HQPickerResult>`. Each `HQPickerResult` contains:
- `asset`: The original `AssetEntity?` (if picked from gallery).
- `file`: The `File?` representation or processed file (if cropped/compressed or picked from device file system).
