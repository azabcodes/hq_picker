import 'dart:io';
import 'package:photo_manager/photo_manager.dart';

/// A wrapper class that holds the original [AssetEntity] and its processed [File] (if any).
class HQPickerResult {
  /// The original asset from the device gallery.
  final AssetEntity asset;

  /// The processed file (e.g. after cropping and compression).
  /// This may be null if the asset was not processed (e.g. video/audio files or if processing is disabled).
  final File? file;

  const HQPickerResult({
    required this.asset,
    this.file,
  });
}
