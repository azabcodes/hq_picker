import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../hq_picker.dart';
import 'tools/media_editor.dart';

/// Handles asset processing (cropping / compression) and
/// file-system picking (documents and directories).
class HQPickerProcessor {
  /// Resolves the underlying [File] from an [AssetEntity].
  /// Uses [originFile] first to avoid copying large files (500MB+) to cache and causing OOM crashes.
  static Future<File?> _resolveAssetFile(AssetEntity asset) async {
    try {
      final f = await asset.originFile ?? await asset.file;
      return f;
    } catch (_) {
      return await asset.originFile ?? await asset.file;
    }
  }

  /// Processes a list of [AssetEntity] items applying cropping / compression
  /// as configured in [config]. Shows a loading dialog only if processing is required.
  static Future<List<HQPickerResult>> processAssets(
    BuildContext context,
    List<AssetEntity> assets,
    HQPickerConfig config,
  ) async {
    if (assets.isEmpty) return [];

    final bool needsProcessing = config.compressImage;
    BuildContext? dialogContext;

    if (needsProcessing && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogContext = ctx;
          return config.loadingWidget ?? const Center(child: CircularProgressIndicator());
        },
      );
    }

    List<HQPickerResult> finalResult = [];
    try {
      for (var asset in assets) {
        File? file = await _resolveAssetFile(asset);
        if (asset.type == AssetType.image && file != null) {
          if (config.compressImage) {
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
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
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
      try {
        final XTypeGroup typeGroup = XTypeGroup(
          label: 'documents',
          extensions: allowedExtensions,
        );
        final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
        if (file != null) {
          return [HQPickerResult(file: File(file.path))];
        }
      } catch (e) {
        debugPrint('HQPicker pickDocument error: $e');
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
      try {
        final String? path = await getDirectoryPath();
        if (path != null) {
          return [HQPickerResult(file: File(path))];
        }
      } catch (e) {
        debugPrint('HQPicker pickDirectory error: $e');
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
