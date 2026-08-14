// ignore_for_file: use_build_context_synchronously

library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'src/core/config/hq_picker_config.dart';
import 'src/core/config/hq_picker_result.dart';
import 'src/core/config/hq_picker_shape.dart';
import 'src/core/hq_picker_processor.dart';
import 'src/core/tools/media_services.dart';
import 'src/instagram/hq_instagram_picker.dart';
import 'src/telegram/telegram_media_picker.dart';

export 'package:photo_manager/photo_manager.dart';
export 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

export 'src/core/components/camera_image_setting.dart';
export 'src/core/components/hq_media_preview_dialog.dart';
export 'src/core/config/hq_picker_config.dart';
export 'src/core/config/hq_picker_enums.dart';
export 'src/core/config/hq_picker_icons.dart';
export 'src/core/config/hq_picker_localizations.dart';
export 'src/core/config/hq_picker_result.dart';
export 'src/core/config/hq_picker_shape.dart';
export 'src/core/config/hq_picker_theme.dart';
export 'src/core/tools/media_services.dart';
export 'src/instagram/hq_instagram_asset_item.dart';
export 'src/instagram/hq_instagram_picker.dart';
export 'src/telegram/telegram_media_picker.dart';

/// Unified entry-point for the HQPicker library.
///
/// All methods are static — you never need to instantiate [HQPicker] directly.
///
/// ### Quick Start
/// ```dart
/// // Instagram style
/// final files = await HQPicker.pick(
///   context: context,
///   shape: HQPickerShape.instagram,
///   maxCount: 5,
/// );
///
/// // Telegram style
/// final files = await HQPicker.pick(
///   context: context,
///   shape: HQPickerShape.telegram,
/// );
/// ```
class HQPicker {
  HQPicker._();

  // ── Instagram ─────────────────────────────────────────────────────────────

  /// Pushes the Instagram-style full-screen picker onto the navigator stack
  /// and returns the picked & processed results.
  static Future<List<HQPickerResult>> instagramPicker({
    required BuildContext context,
    required int maxCount,
    required HQPickerRequestType requestType,
    HQPickerConfig config = const HQPickerConfig(),
  }) async {
    final result = await Navigator.push<List<AssetEntity>>(
      context,
      MaterialPageRoute(
        builder: (_) => HQInstagramPicker(
          maxCount: maxCount,
          requestType: requestType,
          config: config,
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      if (!context.mounted) return [];
      return await HQPickerProcessor.processAssets(context, result, config);
    }
    return [];
  }

  // ── Telegram ──────────────────────────────────────────────────────────────

  /// Slides the Telegram-style bottom-sheet picker up over the current screen
  /// and returns the picked & processed results.
  static Future<List<HQPickerResult>> telegram({
    required BuildContext context,
    required int maxCount,
    HQPickerRequestType requestType = HQPickerRequestType.all,
    HQPickerConfig config = const HQPickerConfig(),
    bool isRealCameraView = false,
  }) async {
    final completer = Completer<List<HQPickerResult>>();
    final key = GlobalKey<HQPickerTelegramMediaPickersState>();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => HQPickerTelegramMediaPickers(
        key: key,
        maxCountPickMedia: maxCount,
        maxCountPickFiles: maxCount,
        requestType: requestType,
        isRealCameraView: isRealCameraView,
        config: config,
        onMediaPicked: (assets, files) async {
          if (overlayEntry.mounted) overlayEntry.remove();

          List<HQPickerResult> results = [];
          if (assets != null && assets.isNotEmpty) {
            results = await HQPickerProcessor.processAssets(context, assets, config);
          } else if (files != null && files.isNotEmpty) {
            results = files.map((f) => HQPickerResult(file: File(f.path))).toList();
          }
          if (!completer.isCompleted) completer.complete(results);
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      key.currentState?.toggleSheet(context);
    });

    return completer.future;
  }

  // ── Unified pick ──────────────────────────────────────────────────────────

  /// Unified entry-point — launches the correct picker UI for [shape].
  static Future<List<HQPickerResult>> pick({
    required BuildContext context,
    required HQPickerShape shape,
    int maxCount = 1,
    HQPickerRequestType requestType = HQPickerRequestType.all,
    HQPickerConfig config = const HQPickerConfig(),
    List<String>? allowedExtensions,
  }) async {
    switch (shape) {
      case HQPickerShape.instagram:
        return instagramPicker(
          context: context,
          maxCount: maxCount,
          requestType: requestType,
          config: config,
        );
      case HQPickerShape.telegram:
        return telegram(
          context: context,
          maxCount: maxCount,
          requestType: requestType,
          config: config,
        );
      case HQPickerShape.document:
        return HQPickerProcessor.pickDocument(
          context: context,
          shape: shape,
          allowedExtensions: allowedExtensions,
          maxCount: maxCount,
          config: config,
        );
      case HQPickerShape.directory:
        return HQPickerProcessor.pickDirectory(
          context: context,
          shape: shape,
          maxCount: maxCount,
        );
    }
  }

  // ── Convenience shortcuts ─────────────────────────────────────────────────

  /// Picks images (Instagram shape by default).
  static Future<List<HQPickerResult>> pickImage({
    required BuildContext context,
    HQPickerShape shape = HQPickerShape.instagram,
    int maxCount = 1,
    HQPickerConfig config = const HQPickerConfig(),
  }) => pick(
    context: context,
    shape: shape,
    maxCount: maxCount,
    requestType: HQPickerRequestType.image,
    config: config,
  );

  /// Picks videos (Telegram shape by default).
  static Future<List<HQPickerResult>> pickVideo({
    required BuildContext context,
    HQPickerShape shape = HQPickerShape.telegram,
    int maxCount = 1,
    HQPickerConfig config = const HQPickerConfig(),
  }) => pick(
    context: context,
    shape: shape,
    maxCount: maxCount,
    requestType: HQPickerRequestType.video,
    config: config,
  );

  /// Picks a document file using the native file picker.
  static Future<List<HQPickerResult>> pickDocument({
    BuildContext? context,
    HQPickerShape shape = HQPickerShape.document,
    List<String>? allowedExtensions,
    int maxCount = 1,
    HQPickerConfig config = const HQPickerConfig(),
  }) => HQPickerProcessor.pickDocument(
    context: context,
    shape: shape,
    allowedExtensions: allowedExtensions,
    maxCount: maxCount,
    config: config,
  );

  /// Picks a directory using the native directory picker.
  static Future<List<HQPickerResult>> pickDirectory({
    BuildContext? context,
    HQPickerShape shape = HQPickerShape.directory,
  }) => HQPickerProcessor.pickDirectory(
    context: context,
    shape: shape,
  );
  /// Clears temporary media file cache generated by PhotoManager in app cache storage.
  static Future<void> clearCache() async {
    try {
      await PhotoManager.clearFileCache();
    } catch (_) {}
  }
}
