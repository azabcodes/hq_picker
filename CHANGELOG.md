## 0.0.3

### 🔧 Android Build Compatibility
* **Gradle wrapper** upgraded from `8.12` → `8.14.1` (satisfies Flutter's upcoming minimum requirement).
* **Android Gradle Plugin (AGP)** upgraded from `8.7.3` → `8.11.1` — resolves `checkDebugAarMetadata` build failures caused by `androidx.activity`, `androidx.core`, and `androidx.navigationevent` dependencies requiring AGP ≥ 8.9.1.
* **Kotlin Gradle Plugin (KGP)** upgraded from `2.1.0` → `2.2.20`.
* **JVM target mismatch fix**: Added a targeted `subprojects` block in root `build.gradle.kts` that enforces consistent Java/Kotlin JVM target (`17`) for `photo_manager`, resolving `Inconsistent JVM Target Compatibility` build errors.
* **App JVM target** updated from `VERSION_11` → `VERSION_17` in `app/build.gradle.kts`.
* **`UCropActivity` declaration** added to `AndroidManifest.xml` — fixes crash when using `image_cropper` (`ActivityNotFoundException: UCropActivity`).
* **`android:enableOnBackInvokedCallback="true"`** added to `AndroidManifest.xml` — suppresses predictive back gesture warning.



### 🗂️ Example App Overhaul
* Replaced the single-screen example with a comprehensive 3-tab showcase:
  * **Tab 1 — Shapes**: Cards for all 8 `HQPickerShape` variants (`instagram`, `custom`, `bottomSheet`, `scaffoldBottomSheet`, `bottomSheetImageSelector`, `telegram`, `document`, `directory`).
  * **Tab 2 — Types**: Cards demonstrating `pickImage`, `pickVideo`, `pickDocument`, `pickDirectory`, and `pick` with all `HQPickerRequestType` values and config combinations (crop, compress).
  * **Tab 3 — Telegram Inline**: Inline `HQPickerTelegramMediaPickers` widget with toggle button, displaying picked assets and files.
* Results panel shown inline under the grid with thumbnail previews and type icons.

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