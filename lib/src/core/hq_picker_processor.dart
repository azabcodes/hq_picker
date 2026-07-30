import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../hq_picker.dart';
import 'tools/isolate_services.dart';
import 'tools/media_editor.dart';

/// Handles asset processing (cropping / compression) and
/// file-system picking (documents and directories).
class HQPickerProcessor {
  /// Resolves the underlying [File] from an [AssetEntity] in a background isolate.
  static Future<File?> _resolveAssetFile(AssetEntity asset) async {
    final assetId = asset.id;
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
      return path != null ? File(path) : await asset.file;
    } catch (_) {
      return await asset.file;
    }
  }

  /// Processes a list of [AssetEntity] items applying cropping / compression
  /// as configured in [config]. Shows a loading dialog while working.
  static Future<List<HQPickerResult>> processAssets(
    BuildContext context,
    List<AssetEntity> assets,
    HQPickerConfig config,
  ) async {
    if (assets.isEmpty) return [];

    bool dialogShown = false;
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => config.loadingWidget ?? const Center(child: CircularProgressIndicator()),
      );
      dialogShown = true;
    }

    List<HQPickerResult> finalResult = [];
    try {
      for (var asset in assets) {
        File? file = await _resolveAssetFile(asset);
        if (asset.type == AssetType.image && file != null) {
          if (config.enableCropping || config.compressImage) {
            if (!context.mounted) {
              finalResult.add(HQPickerResult(asset: asset, file: file));
              continue;
            }
            File? processed = await HQPickerMediaEditor.processImage(
              context,
              file,
              config,
            );
            finalResult.add(HQPickerResult(asset: asset, file: processed ?? file));
          } else {
            finalResult.add(HQPickerResult(asset: asset, file: file));
          }
        } else {
          finalResult.add(HQPickerResult(asset: asset, file: file));
        }
      }
    } finally {
      if (dialogShown && context.mounted) {
        Navigator.pop(context);
      }
    }
    return finalResult;
  }

  /// Picks a document file from the file system or delegates to [HQPicker.pick]
  /// for UI-based shapes.
  static Future<List<HQPickerResult>> pickDocument({
    BuildContext? context,
    HQPickerShape shape = HQPickerShape.document,
    List<String>? allowedExtensions,
    int maxCount = 1,
    HQPickerConfig config = const HQPickerConfig(),
  }) async {
    if (shape == HQPickerShape.document) {
      final XTypeGroup typeGroup = XTypeGroup(
        label: 'documents',
        extensions: allowedExtensions,
      );
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file != null) {
        return [HQPickerResult(file: File(file.path))];
      }
      return [];
    }
    if (context == null) {
      throw ArgumentError('BuildContext context is required for shape $shape');
    }
    // For any other shape the caller is expected to use HQPicker.pick directly.
    throw ArgumentError('pickDocument does not support shape $shape. Use HQPicker.pick instead.');
  }

  /// Picks a directory from the file system or delegates to [HQPicker.pick]
  /// for UI-based shapes.
  static Future<List<HQPickerResult>> pickDirectory({
    BuildContext? context,
    HQPickerShape shape = HQPickerShape.directory,
    int maxCount = 1,
  }) async {
    if (shape == HQPickerShape.directory) {
      final String? path = await getDirectoryPath();
      if (path != null) {
        return [HQPickerResult(file: File(path))];
      }
      return [];
    }
    if (context == null) {
      throw ArgumentError('BuildContext context is required for shape $shape');
    }
    // For any other shape the caller is expected to use HQPicker.pick directly.
    throw ArgumentError('pickDirectory does not support shape $shape. Use HQPicker.pick instead.');
  }
}
