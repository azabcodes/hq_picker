import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

import '../config/hq_picker_config.dart';

class HQPickerMediaEditor {
  static Future<File?> processImage(
    BuildContext context,
    File imageFile,
    HQPickerConfig config,
  ) async {
    File? result = imageFile;

    // 1. Cropping
    if (config.enableCropping) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: result.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: config.localizations.crop,
            toolbarColor: config.theme.appbarColor,
            toolbarWidgetColor: config.theme.textColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: config.localizations.crop),
        ],
      );

      if (croppedFile != null) {
        result = File(croppedFile.path);
      }
    }

    // 2. Compression
    if (config.compressImage) {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        result.path,
        targetPath,
        quality: config.compressQuality,
      );

      if (compressedFile != null) {
        result = File(compressedFile.path);
      }
    }

    return result;
  }
}
