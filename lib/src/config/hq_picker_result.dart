import 'dart:io';
import 'package:photo_manager/photo_manager.dart';

/// A wrapper class that holds the original [AssetEntity] (if any) and its processed [File] (if any).
class HQPickerResult {
  /// The original asset from the device gallery (optional for generic files/documents).
  final AssetEntity? asset;

  /// The processed file or direct file path.
  /// This may be null if the asset was not processed into a File yet.
  final File? file;

  const HQPickerResult({
    this.asset,
    this.file,
  });
}
