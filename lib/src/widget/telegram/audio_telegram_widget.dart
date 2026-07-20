// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hq_picker/src/telegram_media_picker.dart';
import 'package:hq_picker/src/tools/extension/extensions_telegram_picker.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:native_android_path/native_android_path.dart';
import 'package:path/path.dart' as path;

class HQPickerAudioTelegramWidget extends StatefulWidget {
  /// The scroll controller for handling the scrolling behavior.
  final ScrollController scrollController;

  /// The maximum number of audio files that can be selected.
  final int maxCountPickFiles;

  /// Callback function triggered when files are selected.
  final OnMediaPicked onFilesSelected;

  /// The overlay entry used for displaying the widget as an overlay.
  final OverlayEntry overlayEntry;

  /// Callback function to toggle the visibility of the bottom sheet.
  final VoidCallback toggleSheet;

  /// The text displayed when the audio list is empty.
  final String textEmptyListAudio;

  /// The text style applied to the empty list message.
  final TextStyle textStyleEmptyListText;

  /// Constructor for the HQPickerAudioTelegramWidget class.
  const HQPickerAudioTelegramWidget({
    super.key,
    required this.scrollController,
    required this.maxCountPickFiles,
    required this.onFilesSelected,
    required this.overlayEntry,
    required this.toggleSheet,
    required this.textEmptyListAudio,
    required this.textStyleEmptyListText,
  });

  @override
  State<HQPickerAudioTelegramWidget> createState() =>
      _AudioTelegramWidgetState();
}

class _AudioTelegramWidgetState extends State<HQPickerAudioTelegramWidget> {
  final StreamController<List<FileSystemEntity>> _fileStreamController =
      StreamController<List<FileSystemEntity>>();

  List<FileSystemEntity> selectedFiles = [];

  void _sendSelectedFiles() {
    widget.onFilesSelected(null, selectedFiles);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _listFiles(allowedExtensions: allowedExtensionsAudio);
  }

  Future<void> _listFiles({required List<String> allowedExtensions}) async {
    try {
      List<FileSystemEntity> allFiles = [];

      if (Platform.isAndroid) {
        final nativeAndroidPath = NativeAndroidPath();
        var publicDirectories = await nativeAndroidPath.getAllPaths();
        for (var dirType in publicDirectories.values) {
          String? directory = dirType;
          if (directory != null) {
            Directory dir = Directory(directory);
            if (await dir.exists()) {
              allFiles.addAll(await _getFilesRecursively(dir));
            }
          }
        }
      } else if (Platform.isIOS) {
        final externalPathIos = ExternalPathIosMac();
        var publicDirectories = await getPublicDirectories();
        for (DirectoryType? dirType in publicDirectories) {
          if (dirType != null) {
            String? directory = await externalPathIos.getDirectoryPath(
              directory: dirType,
            );
            if (directory != null) {
              Directory dir = Directory(directory);
              if (await dir.exists()) {
                allFiles.addAll(await _getFilesRecursively(dir));
              }
            }
          }
        }
      } else {
        throw UnsupportedError('Platform not supported');
      }

      allFiles = allFiles.where((file) {
        String extension = path.extension(file.path).toLowerCase();
        return allowedExtensions.contains(extension);
      }).toList();

      debugPrint('Total files found: ${allFiles.length}');
      _fileStreamController.add(allFiles);
    } catch (e) {
      debugPrint('Error: $e');
      _fileStreamController.addError(e.toString());
    }
  }

  Future<List<FileSystemEntity>> _getFilesRecursively(
    Directory directory,
  ) async {
    List<FileSystemEntity> files = [];
    try {
      await for (var entity in directory.list(
        recursive: true,
        followLinks: true,
      )) {
        if (entity is File) {
          files.add(entity);
        }
      }
    } catch (e) {
      debugPrint('Error reading directory ${directory.path}: $e');
    }
    return files;
  }

  void _toggleSelection(FileSystemEntity file) {
    setState(() {
      if (selectedFiles.contains(file)) {
        selectedFiles.remove(file);
      } else if (selectedFiles.length < widget.maxCountPickFiles) {
        selectedFiles.add(file);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<FileSystemEntity>>(
          stream: _fileStreamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<FileSystemEntity> files = snapshot.data!;
              return Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        height: 7,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        color: theme.primaryColor,
                        child: ListView.builder(
                          controller: widget.scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            FileSystemEntity file = files[index];
                            String fileExtension = path
                                .extension(file.path)
                                .toLowerCase();
                            bool isSelected = selectedFiles.contains(file);

                            return InkWell(
                              onTap: () => _toggleSelection(file),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.primaryColorLight
                                      : theme.colorScheme.secondary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                      offset: const Offset(2, 2),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.7),
                                      offset: const Offset(-2, -2),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 35,
                                    height: 35,
                                    color: Colors.white,
                                    child: getIconForFile(fileExtension),
                                  ),
                                  title: Text(
                                    file.path.split('/').last,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.data == null) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.textEmptyListAudio,
                    style: widget.textStyleEmptyListText,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20.0),
                  ),
                ),
                child: const SizedBox.shrink(),
              );
            }
          },
        ),
        if (selectedFiles.isNotEmpty)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.10,
            right: 30,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // دایره اصلی
                InkResponse(
                  onTap: () {
                    debugPrint(
                      'Selected files: ${selectedFiles.map((f) => f.path).toList()}',
                    );
                    _sendSelectedFiles();
                    widget.toggleSheet();
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(Icons.send, color: theme.colorScheme.onPrimary),
                  ),
                ),

                // نمایش تعداد فایل‌های انتخاب‌شده
                if (selectedFiles.isNotEmpty)
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: Container(
                      alignment: Alignment.center,
                      width: 35.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2.0),
                      ),
                      child: Text(
                        '${selectedFiles.length}',
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget getIconForFile(String fileExtension) {
    String normalizedExtension = fileExtension.startsWith('.')
        ? fileExtension
        : '.$fileExtension';

    Map<String, IconData> icons = {
      '.mp3': Icons.play_circle_fill,
      '.wav': Icons.play_circle_fill,
      '.aac': Icons.play_circle_fill,
      '.ogg': Icons.play_circle_fill,
      '.flac': Icons.play_circle_fill,
      '.amr': Icons.play_circle_fill,
      '.m4a': Icons.play_circle_fill,
      '.wma': Icons.play_circle_fill,
    };

    IconData iconData = icons.containsKey(normalizedExtension)
        ? icons[normalizedExtension]!
        : LucideIcons.file;

    int hash = normalizedExtension.hashCode;
    Color fixedColor = Color((hash & 0xFFFFFF) + 0xFF000000);

    return Icon(iconData, color: fixedColor);
  }
}
