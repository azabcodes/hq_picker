## 1.0.0

* **Initial Release of `hq_picker` package!**
* **BLoC Architecture**: Entire package built with `flutter_bloc` and `equatable` ensuring high performance, 60fps scrolling, and zero `setState` sluggishness.
* **Pagination (Lazy-Loading)**: Seamlessly loads large galleries (images/videos) in batches to prevent memory leaks and freezing.
* **Telegram-Style Picker**: Draggable bottom sheet with tabs for Gallery, Audio, and Files with smooth UI transitions.
* **Instagram-Style Picker**: Full-page preview with grid selection and a built-in camera functionality.
* **Custom Pickers**: `HQPickerCustomPicker`, `HQPickerBottomSheets`, and `HQPickerScaffoldBottomSheet` for varied project requirements.
* **File System Access**: Natively fetches and filters Audio (`.mp3`, `.wav`, etc.) and general Device Files natively for both Android and iOS.
* **Cropping & Compression**: Built-in support for editing images with adjustable quality settings.
* **Localization**: Full support for Multiple Languages (English, Arabic, etc.) via Dependency Injection.