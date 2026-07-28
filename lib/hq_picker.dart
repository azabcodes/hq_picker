// ignore_for_file: unnecessary_import

library;

import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:hq_picker/src/core/bloc/hq_picker_bloc.dart';
import 'package:hq_picker/src/core/bloc/hq_picker_event.dart';
import 'package:hq_picker/src/core/bloc/hq_picker_state.dart';
import 'package:hq_picker/src/core/components/camera_image_setting.dart';
import 'package:hq_picker/src/core/config/hq_picker_config.dart';
import 'package:hq_picker/src/core/config/hq_picker_result.dart';
import 'package:hq_picker/src/core/config/hq_picker_shape.dart';
import 'package:hq_picker/src/core/tools/media_editor.dart';
import 'package:hq_picker/src/core/tools/media_services.dart';
import 'package:hq_picker/src/telegram_media_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

export 'package:hq_picker/src/core/components/camera_image_setting.dart';
export 'package:hq_picker/src/core/config/hq_picker_config.dart';
export 'package:hq_picker/src/core/config/hq_picker_icons.dart';
export 'package:hq_picker/src/core/config/hq_picker_localizations.dart';
export 'package:hq_picker/src/core/config/hq_picker_result.dart';
export 'package:hq_picker/src/core/config/hq_picker_shape.dart';
export 'package:hq_picker/src/core/config/hq_picker_theme.dart';
export 'package:hq_picker/src/core/tools/media_services.dart';
export 'package:hq_picker/src/telegram_media_picker.dart';
export 'package:photo_manager/photo_manager.dart';
export 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

/// A stateful widget that allows users to pick media files (images, videos, audio, files) from their device.
///
/// Example:
///```dart
/// List<AssetEntity> selectedAssetList = [];
///
/// ElevatedButton(
///    onPressed: ()  {
///     var picker = const HQPicker(
///      maxCount: 5,
///     requestType: HQPickerRequestType.image,
///      ).instagram(context);
///      picker.then((value) {
///        selectedAssetList = value;
///      convertToFileList();
///       });
///      },
///   child: const Text("Instgram picker"),
/// ),
///
///
/// ```
///
///

class HQPicker extends StatefulWidget {
  static Future<List<HQPickerResult>> _processAssets(
    BuildContext context,
    List<AssetEntity> assets,
    HQPickerConfig config,
  ) async {
    if (!config.enableCropping && !config.compressImage) {
      return assets.map((a) => HQPickerResult(asset: a)).toList();
    }

    bool dialogShown = false;
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      dialogShown = true;
    }

    List<HQPickerResult> finalResult = [];
    try {
      for (var asset in assets) {
        if (asset.type == AssetType.image) {
          File? file = await asset.file;
          if (file != null) {
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
            finalResult.add(HQPickerResult(asset: asset));
          }
        } else {
          finalResult.add(HQPickerResult(asset: asset));
        }
      }
    } finally {
      if (dialogShown && context.mounted) {
        Navigator.pop(context);
      }
    }
    return finalResult;
  }

  /// The maximum number of media files that can be picked.
  final int maxCount;

  /// The type of request being made (e.g. photo, video, etc.).
  final HQPickerRequestType requestType;

  /// The text to display on the confirm button.
  final String confirmText;

  /// The color of the text on the confirm button.
  final Color confirmTextColor;

  /// The color of the text in the widget.
  final Color textColor;

  /// The background color of the widget.
  final Color backgroundColor;

  /// The color of the app bar.
  final Color appbarColor;

  /// The color of the background of the bottom button.
  final Color backBottomColor;

  /// The color of the camera icon.
  final Color iconCameraColor;

  /// The color of the gallery icon.
  final Color iconGalleryColor;

  /// The color of the icon in the selected list.
  final Color iconSelectedListAlbumColor;

  /// The color of the text in the selected list.
  final Color textSelectedListAssetColor;

  /// The color of the dropdown menu.
  final Color backgroundDropDownColor;

  /// The color of the text when it is null.
  final Color nullColorText;

  /// The color of the text when the list is empty.
  final Color? textEmptyListColor;

  /// The text to display when the list is empty.
  final String textEmptyList;

  /// The loading indicator to display while media files are being loaded.
  final Widget? loading;

  /// The camera image settings to use when capturing images.
  final HQPickerCameraImageSettings? cameraImageSettings;

  /// The title of the widget. If null, defaults to [HQPickerLocalizations.gallery]
  /// styled with [HQPickerTheme.resolvedAlbumNameTextStyle].
  final Widget? title;

  /// The configuration for the picker.
  final HQPickerConfig config;

  /// Constructs a new [HQPicker] instance with the given properties.
  ///
  /// The [maxCount] and [requestType] properties are required.
  const HQPicker({
    required this.maxCount,
    required this.requestType,
    this.config = const HQPickerConfig(),
    this.confirmText = 'Send',
    this.confirmTextColor = Colors.white,
    this.textColor = Colors.white,
    this.backgroundColor = const Color(0xFF2A2D3E),
    this.appbarColor = const Color(0xFF2A2D3E),
    this.backBottomColor = Colors.white,
    this.iconCameraColor = Colors.white,
    this.iconGalleryColor = Colors.white,
    this.iconSelectedListAlbumColor = Colors.white,
    this.textSelectedListAssetColor = Colors.white,
    this.backgroundDropDownColor = Colors.white,
    this.nullColorText = Colors.white,
    this.textEmptyListColor = Colors.white,
    this.textEmptyList = 'No albums found.',
    this.loading,
    this.cameraImageSettings,
    this.title,
    super.key,
  });

  /// Displays the Telegram-style sliding media sheet modally.
  static Future<List<HQPickerResult>> telegram({
    required BuildContext context,
    required int maxCount,
    HQPickerRequestType requestType = HQPickerRequestType.all,
    HQPickerConfig config = const HQPickerConfig(),
    bool isRealCameraView = false,
  }) async {
    final Completer<List<HQPickerResult>> completer = Completer();
    final GlobalKey<HQPickerTelegramMediaPickersState> key = GlobalKey();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return HQPickerTelegramMediaPickers(
          key: key,
          maxCountPickMedia: maxCount,
          maxCountPickFiles: maxCount,
          requestType: requestType,
          isRealCameraView: isRealCameraView,
          config: config,
          onMediaPicked: (assets, files) async {
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
            List<HQPickerResult> results = [];
            if (assets != null && assets.isNotEmpty) {
              results = await _processAssets(context, assets, config);
            } else if (files != null && files.isNotEmpty) {
              results = files.map((f) => HQPickerResult(file: File(f.path))).toList();
            }
            if (!completer.isCompleted) {
              completer.complete(results);
            }
          },
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      key.currentState?.toggleSheet(context);
    });

    return completer.future;
  }

  /// Launches the Instagram-style full-screen preview & grid picker.
  static Future<List<HQPickerResult>> instagramPicker({
    required BuildContext context,
    required int maxCount,
    required HQPickerRequestType requestType,
    HQPickerConfig config = const HQPickerConfig(),
    String confirmText = 'Send',
    Color confirmTextColor = Colors.white,
    Color textColor = Colors.white,
    Color backgroundColor = const Color(0xFF2A2D3E),
    Color appbarColor = const Color(0xFF2A2D3E),
  }) async {
    final picker = HQPicker(
      maxCount: maxCount,
      requestType: requestType,
      config: config,
      confirmText: confirmText,
      confirmTextColor: confirmTextColor,
      textColor: textColor,
      backgroundColor: backgroundColor,
      appbarColor: appbarColor,
    );
    return await picker.instagram(context);
  }

  /// Unified static method to launch any picker UI style/shape.
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
        return await instagramPicker(
          context: context,
          maxCount: maxCount,
          requestType: requestType,
          config: config,
        );

      case HQPickerShape.telegram:
        return await telegram(
          context: context,
          maxCount: maxCount,
          requestType: requestType,
          config: config,
        );

      case HQPickerShape.document:
        return await _pickDocumentInline(
          context: context,
          shape: shape,
          allowedExtensions: allowedExtensions,
          maxCount: maxCount,
          config: config,
        );

      case HQPickerShape.directory:
        return await _pickDirectoryInline(
          context: context,
          shape: shape,
          maxCount: maxCount,
        );
    }
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

  /// Picks videos using a specified [HQPickerShape] (defaults to [HQPickerShape.telegram]).
  static Future<List<HQPickerResult>> pickVideo({
    required BuildContext context,
    HQPickerShape shape = HQPickerShape.telegram,
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
    return await _pickDocumentInline(
      context: context,
      shape: shape,
      allowedExtensions: allowedExtensions,
      maxCount: maxCount,
      config: config,
    );
  }

  /// Picks directories using a specified [HQPickerShape] (defaults to [HQPickerShape.directory]).
  static Future<List<HQPickerResult>> pickDirectory({
    BuildContext? context,
    HQPickerShape shape = HQPickerShape.directory,
  }) async {
    return await _pickDirectoryInline(
      context: context,
      shape: shape,
    );
  }

  // ── Internal helpers (inlined from file_picker_service.dart) ──────────────

  static Future<List<HQPickerResult>> _pickDocumentInline({
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

  static Future<List<HQPickerResult>> _pickDirectoryInline({
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

  @override
  State<HQPicker> createState() => _HQPickerState();

  Future<List<HQPickerResult>> instagram(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HQPicker(
          maxCount: maxCount,
          requestType: requestType,
          config: config,
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      if (!context.mounted) return [];
      return await _processAssets(context, result, config);
    }
    return [];
  }
}

class _HQPickerState extends State<HQPicker> with AutomaticKeepAliveClientMixin {
  late final HQPickerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = HQPickerBloc()
      ..add(LoadAlbumsEvent(requestType: widget.requestType, fetchFileCounts: false));
  }

  @override
  void didUpdateWidget(covariant HQPicker oldWidget) {
    if (oldWidget.requestType != widget.requestType) {
      _bloc.add(LoadAlbumsEvent(requestType: widget.requestType, fetchFileCounts: false));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> pickMedia(ImageSource source) async {
    try {
      XFile? pickedFile;
      if (widget.requestType == HQPickerRequestType.video) {
        pickedFile = await ImagePicker().pickVideo(
          source: source,
          preferredCameraDevice:
              widget.cameraImageSettings?.preferredCameraDevice ?? CameraDevice.rear,
        );
      } else {
        pickedFile = await ImagePicker().pickImage(
          source: source,
          imageQuality: widget.cameraImageSettings?.imageQuality,
          preferredCameraDevice:
              widget.cameraImageSettings?.preferredCameraDevice ?? CameraDevice.rear,
          maxWidth: widget.cameraImageSettings?.maxWidth,
          maxHeight: widget.cameraImageSettings?.maxHeight,
        );
      }

      if (pickedFile != null) {
        final mediaFile = File(pickedFile.path);
        _bloc.add(SetCapturedImageEvent(mediaFile));

        try {
          if (widget.requestType != HQPickerRequestType.video) {
            if (Platform.isAndroid) {
              await FlutterSaver.saveImageAndroid(fileImage: mediaFile);
            } else if (Platform.isIOS) {
              await FlutterSaver.saveImageIos(fileImage: mediaFile);
            }
          }
        } catch (e) {
          debugPrint('Save to gallery error: $e');
        }

        _bloc.add(LoadAlbumsEvent(requestType: widget.requestType, fetchFileCounts: false));
      }
    } on PlatformException catch (error) {
      debugPrint('PlatformException: $error');
    } catch (error) {
      debugPrint('Error picking media: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return BlocProvider.value(
      value: _bloc,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: widget.config.theme.backgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: widget.config.theme.appbarColor,
            leading: BackButton(color: widget.config.theme.textColor),
            centerTitle: true,
            title:
                widget.title ??
                Text(
                  widget.config.localizations.gallery,
                  style: widget.config.theme.resolvedAlbumNameTextStyle,
                ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: BlocBuilder<HQPickerBloc, HQPickerState>(
                  builder: (context, state) {
                    return InkResponse(
                      child: Text(
                        widget.config.localizations.confirm,
                        style: widget.config.theme.resolvedConfirmButtonTextStyle,
                      ),
                      onTap: () {
                        List<AssetEntity> finalSelection = [];
                        if (state.selectedAssetList.isEmpty && state.selectedEntity != null) {
                          finalSelection = [state.selectedEntity!];
                        } else {
                          finalSelection = List.from(state.selectedAssetList);
                        }

                        if (finalSelection.isNotEmpty) {
                          Navigator.pop(context, finalSelection);
                        } else {
                          widget.config.showSelectionError(
                            context,
                            widget.config.localizations.emptyList,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          body: BlocBuilder<HQPickerBloc, HQPickerState>(
            builder: (context, state) {
              return Column(
                children: [
                  SizedBox(
                    height: size.height * 0.40,
                    child: state.capturedImage != null
                        ? Image.file(
                            fit: BoxFit.cover,
                            height: size.height,
                            width: size.width,
                            state.capturedImage!,
                          )
                        : (state.selectedEntity == null)
                        ? const SizedBox.shrink()
                        : Stack(
                            children: [
                              Positioned.fill(
                                child: AssetEntityImage(
                                  state.selectedEntity!,
                                  isOriginal: false,
                                  thumbnailSize: const ThumbnailSize.square(250),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: IconTheme(
                                        data: const IconThemeData(color: Colors.red),
                                        child: widget.config.icons.error,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (state.selectedEntity!.type == AssetType.video)
                                Positioned.fill(
                                  child: Center(
                                    child: IconTheme(
                                      data: const IconThemeData(color: Colors.white, size: 50),
                                      child: widget.config.icons.play,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DecoratedBox(
                          decoration: const BoxDecoration(color: Color(0xFF212332)),
                          child: Row(
                            children: [
                              if (state.selectedAlbum != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      _showAlbumSelector(context, state);
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          state.selectedAlbum!.name == 'Recent'
                                              ? widget.config.localizations.recent
                                              : state.selectedAlbum!.name,
                                          style: widget.config.theme.resolvedAlbumNameTextStyle
                                              .copyWith(fontSize: 20.0),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5.0),
                                          child: IconTheme(
                                            data: IconThemeData(
                                              color: widget.config.theme.iconGalleryColor,
                                            ),
                                            child: widget.config.icons.dropdown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  _bloc.add(ToggleMultipleSelectionEvent());
                                },
                                icon: IconTheme(
                                  data: IconThemeData(color: widget.config.theme.iconGalleryColor),
                                  child: state.isMultiple
                                      ? const Icon(Icons.add_a_photo_outlined)
                                      : const Icon(Icons.add_a_photo),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await pickMedia(ImageSource.camera);
                                },
                                icon: IconTheme(
                                  data: IconThemeData(color: widget.config.theme.iconCameraColor),
                                  child: widget.config.icons.camera,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: state.assetsList.isEmpty
                              ? Center(
                                  child: state.status == HQPickerStatus.loading
                                      ? widget.loading ?? const CircularProgressIndicator.adaptive()
                                      : Text(
                                          widget.textEmptyList,
                                          style: widget.config.theme.resolvedEmptyListTextStyle,
                                        ),
                                )
                              : NotificationListener<ScrollNotification>(
                                  onNotification: (ScrollNotification scrollInfo) {
                                    if (scrollInfo.metrics.pixels >=
                                        scrollInfo.metrics.maxScrollExtent - 200) {
                                      _bloc.add(LoadMoreAssetsEvent());
                                    }
                                    return false;
                                  },
                                  child: GridView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      mainAxisSpacing: 1,
                                      crossAxisSpacing: 1,
                                    ),
                                    itemCount:
                                        state.assetsList.length + (state.isLoadingMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index < state.assetsList.length) {
                                        AssetEntity assetEntity = state.assetsList[index];
                                        return assetWidget(assetEntity, state);
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator.adaptive(),
                                        );
                                      }
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAlbumSelector(BuildContext context, HQPickerState state) {
    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 39, 36, 36),
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      builder: (_) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: state.albumList.length,
          itemBuilder: (context, index) {
            final album = state.albumList[index];
            return ListTile(
              onTap: () {
                _bloc.add(ChangeAlbumEvent(album));
                Navigator.pop(context);
              },
              title: Text(
                album.name == 'Recent' ? widget.config.localizations.gallery : album.name,
                style: widget.config.theme.resolvedAlbumNameTextStyle.copyWith(fontSize: 18.0),
              ),
            );
          },
        );
      },
    );
  }

  Widget assetWidget(AssetEntity assetEntity, HQPickerState state) {
    final isSelected = state.selectedAssetList.contains(assetEntity);
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          _bloc.add(SelectEntityEvent(assetEntity));
          if (!state.isMultiple) {
            _bloc.add(SetSelectedAssetsEvent([assetEntity]));
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: AssetEntityImage(
                assetEntity,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(250),
                thumbnailFormat: ThumbnailFormat.jpeg,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: IconTheme(
                      data: const IconThemeData(color: Colors.red),
                      child: widget.config.icons.error,
                    ),
                  );
                },
              ),
            ),
            if (assetEntity.type == AssetType.video)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconTheme(
                        data: const IconThemeData(color: Colors.white, size: 12),
                        child: widget.config.icons.play,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatDuration(assetEntity.duration),
                        style: widget.config.theme.resolvedVideoDurationTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
            Positioned.fill(
              child: Container(
                color: assetEntity == state.selectedEntity ? Colors.white60 : Colors.transparent,
              ),
            ),
            if (state.isMultiple)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _bloc.add(ToggleAssetSelectionEvent(assetEntity, widget.maxCount));
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.config.theme.badgeBackgroundColor
                              : Colors.white12,
                          shape: BoxShape.circle,
                          border: Border.all(width: 1.5, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            isSelected ? '${state.selectedAssetList.indexOf(assetEntity) + 1}' : '',
                            style: widget.config.theme.resolvedBadgeTextStyle.copyWith(
                              color: isSelected ? null : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  bool get wantKeepAlive => true;
}
