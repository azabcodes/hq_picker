import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
