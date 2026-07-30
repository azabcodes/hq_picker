import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

import '../config/hq_picker_config.dart';
import 'isolate_services.dart';

class HQPickerMediaEditor {
  static Future<File?> processImage(
    BuildContext context,
    File imageFile,
    HQPickerConfig config,
  ) async {
    File? result = imageFile;

    // 1. Cropping (Requires interactive native UI on Main Thread)
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

    // 2. Compression (Offloaded to background isolate)
    if (config.compressImage) {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final sourcePath = result.path;
      final quality = config.compressQuality;

      try {
        final compressedPath = await IsolateServices.run<String?, Map<String, dynamic>>(
          function: (params, _) async {
            final src = params!['sourcePath'] as String;
            final target = params['targetPath'] as String;
            final q = params['quality'] as int;

            final compressed = await FlutterImageCompress.compressAndGetFile(
              src,
              target,
              quality: q,
            );
            return compressed?.path;
          },
          input: {
            'sourcePath': sourcePath,
            'targetPath': targetPath,
            'quality': quality,
          },
        );

        if (compressedPath != null) {
          result = File(compressedPath);
        }
      } catch (_) {
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          sourcePath,
          targetPath,
          quality: quality,
        );
        if (compressedFile != null) {
          result = File(compressedFile.path);
        }
      }
    }

    return result;
  }
}

