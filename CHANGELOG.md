## 0.0.2

* **Unified `HQPickerShape` API**: Added `HQPickerShape` enum unifying all 8 picker UI shapes (`instagram`, `custom`, `bottomSheet`, `scaffoldBottomSheet`, `bottomSheetImageSelector`, `telegram`, `document`, `directory`).
* **Shape-Centric Launchers**: Added `HQPicker.pick(...)`, `HQPickerFilePicker.pick(...)`, `pickImage`, `pickVideo`, `pickDocument`, and `pickDirectory` static methods across `HQPicker` and `HQPickerFilePicker`.
* **Telegram Modal Launcher**: Added static `HQPicker.telegram(...)` modal presenter returning `Future<List<HQPickerResult>>`.
* **Flexible Results**: Updated `HQPickerResult` to support raw files without requiring an `AssetEntity`.

## 0.0.1

* **Initial Release of `hq_picker` package!**
* **BLoC Architecture**: Entire package built with `flutter_bloc` and `equatable` ensuring high performance, 60fps scrolling, and zero `setState` sluggishness.
* **Pagination (Lazy-Loading)**: Seamlessly loads large galleries (images/videos) in batches to prevent memory leaks and freezing.
* **Telegram-Style Picker**: Draggable bottom sheet with tabs for Gallery, Audio, and Files with smooth UI transitions.
* **Instagram-Style Picker**: Full-page preview with grid selection and a built-in camera functionality.
* **Custom Pickers**: `HQPickerCustomPicker`, `HQPickerBottomSheets`, and `HQPickerScaffoldBottomSheet` for varied project requirements.
* **File System Access**: Natively fetches and filters Audio (`.mp3`, `.wav`, etc.) and general Device Files natively for both Android and iOS.
* **Cropping & Compression**: Built-in support for editing images with adjustable quality settings.
* **Localization**: Full support for Multiple Languages (English, Arabic, etc.) via Dependency Injection.