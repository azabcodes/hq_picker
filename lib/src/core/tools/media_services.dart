import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:native_android_path/native_android_path.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../config/hq_picker_config.dart';
import '../extension/extensions_telegram_picker.dart';
import 'isolate_services.dart';

enum HQPickerRequestType { common, audio, image, video, all }

RequestType _mapRequestType(HQPickerRequestType requestType) {
  switch (requestType) {
    case HQPickerRequestType.common:
      return RequestType.common;
    case HQPickerRequestType.audio:
      return RequestType.audio;
    case HQPickerRequestType.image:
      return RequestType.image;
    case HQPickerRequestType.video:
      return RequestType.video;
    default:
      return RequestType.all;
  }
}

class HQPickerMediaServices {
  static final List<String> _restrictedAndroidDirectories = [
    '/data',
    '/storage/emulated/0/Android/data',
    '/storage/emulated/0/Android/obb',
  ];

  static bool _isRestrictedAndroidDirectory(String directory) {
    if (!Platform.isAndroid) return false;

    final normalizedDirectory = path.normalize(directory);
    return _restrictedAndroidDirectories.any((restrictedDirectory) {
      final normalizedRestrictedDirectory = path.normalize(restrictedDirectory);
      return normalizedDirectory == normalizedRestrictedDirectory ||
          path.isWithin(normalizedRestrictedDirectory, normalizedDirectory);
    });
  }

  static Future<bool> requestPermissions(
    BuildContext context,
    HQPickerConfig config,
  ) async {
    if (Platform.isIOS) {
      final photoStatus = await Permission.photos.request();
      if (photoStatus.isGranted || photoStatus.isLimited) return true;
    } else {
      final status = await Permission.storage.request();
      if (status.isGranted) return true;

      final photoStatus = await Permission.photos.request();
      if (photoStatus.isGranted || photoStatus.isLimited) return true;
    }

    // Show dialog
    if (context.mounted) {
      if (config.permissionDialogBuilder != null) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => config.permissionDialogBuilder!(
            ctx,
            () {},
            () => openAppSettings(),
          ),
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(
              config.localizations.permissionRequired,
              style: config.theme.resolvedDialogTitleTextStyle,
            ),
            content: Text(
              config.localizations.permissionDenied,
              style: config.theme.resolvedDialogContentTextStyle,
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  config.localizations.cancel,
                  style: config.theme.resolvedDialogCancelTextStyle,
                ),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(ctx);
                },
                child: Text(
                  config.localizations.openSettings,
                  style: config.theme.resolvedDialogConfirmTextStyle,
                ),
              ),
            ],
          ),
        );
      }
    }
    return false;
  }

  static Future<List<AssetPathEntity>> loadAlbums(
    HQPickerRequestType requestType, {
    HQPickerSortOrder sortOrder = HQPickerSortOrder.newestFirst,
  }) async {
    var permission = await PhotoManager.requestPermissionExtend();
    List<AssetPathEntity> albumList = [];
    if (permission.isAuth == true) {
      final photoManagerRequestType = _mapRequestType(requestType);
      final filterOption = FilterOptionGroup(
        orders: [
          OrderOption(
            type: OrderOptionType.createDate,
            asc: sortOrder == HQPickerSortOrder.oldestFirst,
          ),
        ],
      );
      albumList = await PhotoManager.getAssetPathList(
        type: photoManagerRequestType,
        filterOption: filterOption,
      );
    } else {
      PhotoManager.openSetting();
    }
    return albumList;
  }

  static Future<List<AssetEntity>> loadAssets(
    AssetPathEntity selectedAlbum,
  ) async {
    int assetCount = await selectedAlbum.assetCountAsync;
    List<AssetEntity> assetsList = await selectedAlbum.getAssetListRange(
      start: 0,
      end: assetCount,
    );
    return assetsList;
  }

  // Pagination support
  static Future<List<AssetEntity>> loadAssetsPaged(
    AssetPathEntity selectedAlbum,
    int page,
    int perPage,
  ) async {
    List<AssetEntity> assetsList = await selectedAlbum.getAssetListPaged(
      page: page,
      size: perPage,
    );
    return assetsList;
  }

  static Future<List<FileSystemEntity>> _getFilesRecursively(
    Directory dir,
    List<String> allowedExtensions,
  ) async {
    List<FileSystemEntity> files = [];
    try {
      final entities = await dir.list(recursive: false).toList();
      for (var entity in entities) {
        if (entity is File) {
          final extension = path.extension(entity.path).toLowerCase();
          if (allowedExtensions.contains(extension)) {
            files.add(entity);
          }
        } else if (entity is Directory) {
          final dirName = path.basename(entity.path);
          if (!dirName.startsWith('.') && !_isRestrictedAndroidDirectory(entity.path)) {
            files.addAll(await _getFilesRecursively(entity, allowedExtensions));
          }
        }
      }
    } catch (e) {
      debugPrint('Error accessing directory: $e');
    }
    return files;
  }

  static Future<List<FileSystemEntity>> fetchFilesByExtensions(
    List<String> allowedExtensions,
  ) async {
    List<String> dirPaths = [];
    if (Platform.isAndroid) {
      final nativeAndroidPath = NativeAndroidPath();
      var publicDirectories = await nativeAndroidPath.getAllPaths();
      for (var dirType in publicDirectories.values) {
        if (dirType != null && !_isRestrictedAndroidDirectory(dirType)) {
          dirPaths.add(dirType);
        }
      }
    } else if (Platform.isIOS) {
      final externalPathIos = ExternalPathIosMac();
      var publicDirectories = await getPublicDirectories();
      for (DirectoryType? dirType in publicDirectories) {
        if (dirType != null) {
          String? directory = await externalPathIos.getDirectoryPath(directory: dirType);
          if (directory != null) {
            dirPaths.add(directory);
          }
        }
      }
    }

    if (dirPaths.isEmpty) return [];

    try {
      final filePaths = await IsolateServices.run<List<String>, Map<String, dynamic>>(
        function: (params, _) async {
          final paths = params!['paths'] as List<String>;
          final exts = params['extensions'] as List<String>;

          List<String> matchedFilePaths = [];
          for (final dirPath in paths) {
            final dir = Directory(dirPath);
            if (await dir.exists()) {
              final files = await _getFilesRecursively(dir, exts);
              matchedFilePaths.addAll(files.map((f) => f.path));
            }
          }
          return matchedFilePaths;
        },
        input: {
          'paths': dirPaths,
          'extensions': allowedExtensions,
        },
      );
      return filePaths.map((p) => File(p)).toList();
    } catch (_) {
      List<FileSystemEntity> allFiles = [];
      for (final dirPath in dirPaths) {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          allFiles.addAll(await _getFilesRecursively(dir, allowedExtensions));
        }
      }
      return allFiles;
    }
  }
}

// Aliases for backward compatibility in child widgets
class HQPickerMediaServices1 extends HQPickerMediaServices {}

class HQPickerMediaServicesBottomSheet extends HQPickerMediaServices {}

class HQPickerMediaServicesBottomSheetImageSelector extends HQPickerMediaServices {}

class HQPickerMediaServicesDefultBuilder extends HQPickerMediaServices {}

class HQPickerMediaServicesScaffoldBottomSheet extends HQPickerMediaServices {}

class HQPickerMediaServicesTelegramMediaPickers extends HQPickerMediaServices {}

class HQPickerMediaServicesVideoTelegram extends HQPickerMediaServices {}
