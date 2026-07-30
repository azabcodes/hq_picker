import 'dart:io';
import 'package:photo_manager/photo_manager.dart';

import '../tools/isolate_services.dart';

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

  /// Asynchronously resolves and returns the [File].
  /// If [file] is already populated, it returns immediately.
  /// Otherwise, it fetches the file from [asset] in a background isolate to prevent UI freezes.
  Future<File?> getFile() async {
    if (file != null) return file;
    if (asset == null) return null;

    final assetId = asset!.id;
    try {
      final path = await IsolateServices.run<String?, String>(
        function: (id, _) async {
          if (id == null) return null;
          final entity = await AssetEntity.fromId(id);
          final f = await entity?.file;
          return f?.path;
        },
        input: assetId,
      );
      return path != null ? File(path) : null;
    } catch (_) {
      return await asset!.file;
    }
  }
}

