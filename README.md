# HQPicker

A high-performance, fully customizable, multi-mode media picker for Flutter — powered by the BLoC pattern. HQPicker delivers 60fps scrolling, zero `setState` sluggishness, and elegant memory management even with thousands of media files.

---

## Preview & Demo

<p align="center">
  <img src="assets/screenshot_example.png" width="30%" alt="Main Example Screen"/>
  <img src="assets/screenshot_instagram.png" width="30%" alt="Instagram Picker Mode"/>
  <img src="assets/screenshot_telegram.png" width="30%" alt="Telegram Sheet Mode"/>
</p>

### Video Demo

<p align="center">
  <video src="assets/demo.mov" controls width="100%" poster="assets/screenshot_example.png"></video>
</p>

---

## Features

- BLoC Architecture — Zero `setState` inside the picker core. Optimized for fast rebuilds and scalability.
- Isolate-Powered Performance — Heavy file resolving, compression, and file system scanning execute in background isolates using `IsolateServices` to eliminate UI thread freezes when selecting large videos (1GB+) or photos.
- Ultra-Smooth 60/120fps Scrolling — Optimized state rebuild filtering (`buildWhen`) and pre-rendering cache (`scrollCacheExtent: 1500.0`) for stutter-free thumbnail scrolling.
- Instant Selection Response — Single state emission per tap combined with O(1) set lookup (`selectedAssetIdsSet`) for 0ms selection delay.
- Telegram Drag-to-Close Sheet — Draggable bottom sheet with snap points (`0.55`, `1.0`) and smooth swipe-down-to-close behavior.
- Interactive Zoom Preview — Pinch-to-zoom (1.0x to 4.0x) on the top preview image in the Instagram picker.
- Tactile Haptic Feedback — Native feedback (`HapticFeedback.selectionClick()`, `lightImpact()`, `vibrate()`) for media selection, album toggles, and max-count limits.
- System Back Gesture Support — Integrated `PopScope` to catch Android and iOS system back gestures and close picker sheets gracefully.
- Auto Memory Cleanup — Automatically clears temporary thumbnail caches (`PhotoManager.clearFileCache()`) on picker disposal.
- Custom Empty Widget — Pass `emptyWidget` to `HQPickerConfig` for custom empty state illustrations when an album has no assets.
- Two Beautiful Picker Styles — Instagram full-screen preview + Telegram draggable bottom sheet.
- Unified `HQPicker` API — One entry-point for all shapes: `instagram`, `telegram`, `document`, `directory`.
- Conditional Camera Buttons — In the Instagram picker the camera / video-camera buttons are shown only when the `requestType` supports them.
- Pagination Built-in — Lazy-loads media in chunks of 60 to prevent memory leaks and freezing.
- Full Text-Style Theming — Every `Text` widget in the picker (badge, album name, video duration, dialog, snack-bar…) is individually styleable via `HQPickerTheme`.
- Cropping & Compression — Built-in image editing with adjustable quality, shown behind a configurable loading overlay.
- Localization — All visible strings (including `permissionRequired`, `permissionDenied`, `openSettings`, etc.) are configurable via `HQPickerLocalizations`.
- Custom SnackBar / Toast — Provide `onSnackBar` to replace the built-in SnackBar with any toast/overlay you prefer.
- File System Support — Native document and directory pickers via `file_selector`.

---

## Getting Started

```bash
flutter pub add hq_picker
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  hq_picker: ^0.0.9
```

Import in your Dart code:

```dart
import 'package:hq_picker/hq_picker.dart';
```

---

## Platform Setup

### iOS Setup

Add the following keys to your `ios/Runner/Info.plist`:

```xml
<!-- Photo Library Access -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires access to the photo library to pick photos and videos.</string>

<!-- Photo Library Save Permission -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app requires access to save photos to your photo library.</string>

<!-- Camera Access -->
<key>NSCameraUsageDescription</key>
<string>This app requires access to the camera to take photos and videos.</string>

<!-- Microphone Access -->
<key>NSMicrophoneUsageDescription</key>
<string>This app requires access to the microphone for recording videos.</string>
```

> **Note**: Ensure your `ios/Podfile` target platform is set to iOS 13.0 or higher:
> ```ruby
> platform :ios, '13.0'
> ```

### Android Setup

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

---

## Usage

### 1. Unified `HQPicker.pick(...)` — recommended

```dart
// Instagram style (full-screen)
final results = await HQPicker.pick(
  context: context,
  shape: HQPickerShape.instagram,
  maxCount: 5,
  requestType: HQPickerRequestType.image,
);

// Telegram style (sliding sheet)
final results = await HQPicker.pick(
  context: context,
  shape: HQPickerShape.telegram,
  maxCount: 5,
);

// Native document picker
final docs = await HQPicker.pick(
  context: context,
  shape: HQPickerShape.document,
  allowedExtensions: ['pdf', 'docx'],
);

// Native directory picker
final dir = await HQPicker.pickDirectory();
```

### 2. Convenience shortcuts

```dart
// Images only — Instagram style
final images = await HQPicker.pickImage(
  context: context,
  shape: HQPickerShape.instagram,
  maxCount: 5,
);

// Videos only — Telegram style
final videos = await HQPicker.pickVideo(
  context: context,
  shape: HQPickerShape.telegram,
  maxCount: 3,
);

// Documents
final docs = await HQPicker.pickDocument(
  allowedExtensions: ['pdf'],
);
```

### 3. Inline Telegram sheet

```dart
final GlobalKey<HQPickerTelegramMediaPickersState> _key = GlobalKey();

// In your widget tree:
HQPickerTelegramMediaPickers(
  key: _key,
  requestType: HQPickerRequestType.all,
  maxCountPickMedia: 5,
  maxCountPickFiles: 5,
  config: const HQPickerConfig(),
  onMediaPicked: (assets, files) {
    debugPrint('Picked ${assets?.length} assets, ${files?.length} files');
  },
);

// Open / close:
ElevatedButton(
  onPressed: () => _key.currentState?.toggleSheet(context),
  child: const Text('Open Telegram Sheet'),
);
```

---

## Heavy & Large File Handling (Isolate-Powered)

HQPicker runs background isolates for file resolution and compression. When receiving `List<HQPickerResult>`, you can safely access the file via `result.file` or asynchronously via `result.getFile()` without locking the main UI thread.

```dart
final results = await HQPicker.pickVideo(
  context: context,
  shape: HQPickerShape.telegram,
  maxCount: 1,
);

for (final result in results) {
  // Safely resolve the file in background isolate if not already loaded
  final File? file = await result.getFile();
  if (file != null) {
    // Process or upload using Streams / Chunks for large files (1GB+)
    final Stream<List<int>> fileStream = file.openRead();
  }
}
```

---

## Theming — Full Text-Style Control

Every visible text in the picker can be styled independently via `HQPickerTheme`:

```dart
config: HQPickerConfig(
  theme: HQPickerTheme(
    // Colors
    backgroundColor: Color(0xFF1E1E2E),
    appbarColor: Color(0xFF1E1E2E),
    confirmButtonColor: Colors.deepPurple,
    badgeBackgroundColor: Colors.deepPurple,

    // Text styles
    albumNameTextStyle: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    confirmButtonTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    badgeTextStyle: TextStyle(color: Colors.white),
    videoDurationTextStyle: TextStyle(fontSize: 9, color: Colors.yellow),
    emptyListTextStyle: TextStyle(color: Colors.white54, fontSize: 16),
    dialogTitleTextStyle: TextStyle(color: Colors.white),
    dialogContentTextStyle: TextStyle(color: Colors.white70),
    snackBarTextStyle: TextStyle(color: Colors.white),
  ),
),
```

---

## Localization

All strings default to English. Override any or use the built-in Arabic preset:

```dart
// Arabic preset
config: HQPickerConfig(
  localizations: HQPickerLocalizations.ar(),
),

// Or override individual strings
config: HQPickerConfig(
  localizations: HQPickerLocalizations(
    confirm: 'Done',
    gallery: 'My Gallery',
    permissionRequired: 'Access Required',
    permissionDenied: 'Please allow media access in Settings.',
    openSettings: 'Open Settings',
    emptyList: 'No media found',
  ),
),
```

---

## Custom SnackBar / Toast

Replace the default built-in SnackBar with your own notification:

```dart
config: HQPickerConfig(
  showSnackBar: false, // disable built-in snackbar
  onSnackBar: (context, message) {
    // Use any toast library or widget
    Fluttertoast.showToast(msg: message);
  },
),
```

---

## Advanced Config

```dart
config: HQPickerConfig(
  // Image processing
  enableCropping: true,
  compressImage: true,
  compressQuality: 80,

  // Custom loading overlay during processing
  loadingWidget: Center(
    child: CircularProgressIndicator(color: Colors.deepPurple),
  ),

  // Custom icons
  icons: HQPickerIcons(
    camera: Icon(Icons.camera_alt_outlined),
    cameraVideo: Icon(Icons.video_call_outlined), // video camera in Instagram toolbar
    dropdown: Icon(Icons.expand_more),
  ),
),
```

---

## Return Type

All pickers return `List<HQPickerResult>`:

```dart
final results = await HQPicker.pick(...);

for (final result in results) {
  final File? file = await result.getFile(); // Asynchronously resolved File
  final AssetEntity? asset = result.asset;   // Original gallery asset
}
```

---

## HQPickerConfig Reference

| Property | Type | Default | Description |
|---|---|---|---|
| `theme` | `HQPickerTheme` | default dark | All colors & text styles |
| `localizations` | `HQPickerLocalizations` | English | All UI strings |
| `icons` | `HQPickerIcons` | Material icons | All picker icons |
| `enableCropping` | `bool` | `false` | Enable image crop after pick |
| `compressImage` | `bool` | `true` | Compress images before returning |
| `compressQuality` | `int` | `80` | JPEG compression quality (0–100) |
| `showSnackBar` | `bool` | `true` | Show built-in SnackBar on empty selection |
| `onSnackBar` | `Function?` | `null` | Custom SnackBar / toast callback |
| `loadingWidget` | `Widget?` | `CircularProgressIndicator` | Overlay shown during processing |
| `emptyWidget` | `Widget?` | `null` | Custom widget displayed when an album or tab has no assets |
| `maxFileSize` | `int?` | `null` | Max file size in bytes with warning feedback |
| `sortOrder` | `HQPickerSortOrder` | `newestFirst` | Asset sorting order (`newestFirst` or `oldestFirst`) |
| `assetItemBuilder` | `HQAssetItemBuilder?` | `null` | Custom tile builder for grid asset items |
