import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/widgets.dart';

import 'package:hq_picker/hq_picker.dart';

class HQPickerFilePicker {
  /// Universal pick method using [HQPickerShape] for media, documents, or directories.
  static Future<List<HQPickerResult>> pick({
    required BuildContext context,
    required HQPickerShape shape,
    int maxCount = 1,
    HQPickerRequestType requestType = HQPickerRequestType.all,
    HQPickerConfig config = const HQPickerConfig(),
    List<String>? allowedExtensions,
  }) async {
    return await HQPicker.pick(
      context: context,
      shape: shape,
      maxCount: maxCount,
      requestType: requestType,
      config: config,
      allowedExtensions: allowedExtensions,
    );
  }

  /// Picks images using a specified [HQPickerShape] (defaults to [HQPickerShape.instagram]).
  static Future<List<HQPickerResult>> pickImage({
    required BuildContext context,
    HQPickerShape shape = HQPickerShape.instagram,
    int maxCount = 1,
    HQPickerConfig config = const HQPickerConfig(),
  }) async {
    return await pick(
      context: context,
      shape: shape,
      maxCount: maxCount,
      requestType: HQPickerRequestType.image,
      config: config,
    );
  }

  /// Picks videos using a specified [HQPickerShape] (defaults to [HQPickerShape.custom]).
  static Future<List<HQPickerResult>> pickVideo({
    required BuildContext context,
    HQPickerShape shape = HQPickerShape.custom,
    int maxCount = 1,
    HQPickerConfig config = const HQPickerConfig(),
  }) async {
    return await pick(
      context: context,
      shape: shape,
      maxCount: maxCount,
      requestType: HQPickerRequestType.video,
      config: config,
    );
  }

  /// Picks documents using a specified [HQPickerShape] (defaults to [HQPickerShape.document]).
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
    return await pick(
      context: context,
      shape: shape,
      maxCount: maxCount,
      requestType: HQPickerRequestType.all,
      config: config,
      allowedExtensions: allowedExtensions,
    );
  }

  /// Picks directories using a specified [HQPickerShape] (defaults to [HQPickerShape.directory]).
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
    return await pick(
      context: context,
      shape: shape,
      maxCount: maxCount,
    );
  }
}
