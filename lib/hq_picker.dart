// ignore_for_file: unnecessary_import

library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:hq_picker/src/bottom_sheet.dart';
import 'package:hq_picker/src/bottom_sheet_image_selector.dart';
import 'package:hq_picker/src/custom_picker.dart';
import 'package:hq_picker/src/file_picker_service.dart';
import 'package:hq_picker/src/scaffold_bottom_sheet.dart';
import 'package:hq_picker/src/telegram_media_picker.dart';
import 'package:hq_picker/src/tools/media_editor.dart';
import 'package:hq_picker/src/tools/media_services.dart';
import 'package:hq_picker/src/widget/global/camera_image_setting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'package:hq_picker/src/bloc/hq_picker_bloc.dart';
import 'package:hq_picker/src/bloc/hq_picker_event.dart';
import 'package:hq_picker/src/bloc/hq_picker_state.dart';
import 'package:hq_picker/src/config/hq_picker_config.dart';
import 'package:hq_picker/src/config/hq_picker_result.dart';
import 'package:hq_picker/src/config/hq_picker_shape.dart';

export 'package:hq_picker/src/custom_picker.dart';
export 'package:hq_picker/src/file_picker_service.dart';
export 'package:hq_picker/src/telegram_media_picker.dart';
export 'package:hq_picker/src/tools/media_services.dart';
export 'package:hq_picker/src/widget/global/camera_image_setting.dart';
export 'package:photo_manager/photo_manager.dart';
export 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

export 'package:hq_picker/src/config/hq_picker_config.dart';
export 'package:hq_picker/src/config/hq_picker_localizations.dart';
export 'package:hq_picker/src/config/hq_picker_result.dart';
export 'package:hq_picker/src/config/hq_picker_shape.dart';
export 'package:hq_picker/src/config/hq_picker_theme.dart';

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    List<HQPickerResult> finalResult = [];
    for (var asset in assets) {
      if (asset.type == AssetType.image) {
        File? file = await asset.file;
        if (file != null) {
          if (!context.mounted) return finalResult;
          File? processed = await HQPickerMediaEditor.processImage(
            context,
            file,
            config,
          );
          finalResult.add(HQPickerResult(asset: asset, file: processed));
        } else {
          finalResult.add(HQPickerResult(asset: asset));
        }
      } else {
        finalResult.add(HQPickerResult(asset: asset));
      }
    }

    if (context.mounted) Navigator.pop(context);
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

  /// The title of the widget.
  final Widget title;

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
    this.title = const Text(
      'Album',
      style: TextStyle(fontSize: 22, color: Colors.white),
    ),
    super.key,
  });

  static Future<List<HQPickerResult>> customPicker({
    required BuildContext context,
    required int maxCount,
    required HQPickerRequestType requestType,
    HQPickerConfig config = const HQPickerConfig(),
    final Key? key,
    bool showOnlyVideo = true,
    bool showOnlyImage = true,
    String confirmText = 'Send',
    String textTitleImageTabBar = 'Images',
    String textTitleVideoTabBar = 'Videos',
    String textEmptyList = 'No albums found.',
    Color confirmTextColor = Colors.white,
    Color backBottomColor = Colors.white,
    Color backgroundColor = const Color.fromARGB(255, 206, 164, 236),
    Color backgroundAppBarColor = const Color.fromARGB(255, 206, 164, 236),
    Color backgroundTabBarColor = const Color(0xFF6A0DAD),
    Color indicatorColor = Colors.blue,
    Color textEmptyListColor = const Color(0xFF6A0DAD),
    Widget title = const Text(
      'Album',
      style: TextStyle(fontSize: 22, color: Colors.white),
    ),
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HQPickerCustomPicker(
          maxCount: maxCount,
          requestType: requestType,
          showOnlyVideo: showOnlyVideo,
          showOnlyImage: showOnlyImage,
          confirmText: confirmText,
          textTitleImageTabBar: textTitleImageTabBar,
          textTitleVideoTabBar: textTitleVideoTabBar,
          textEmptyList: textEmptyList,
          confirmTextColor: confirmTextColor,
          backBottomColor: backBottomColor,
          backgroundColor: backgroundColor,
          backgroundAppBarColor: backgroundAppBarColor,
          backgroundTabBarColor: backgroundTabBarColor,
          indicatorColor: indicatorColor,
          title: title,
          textEmptyListColor: textEmptyListColor,
          key: key,
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      if (!context.mounted) return [];
      return await _processAssets(context, result, config);
    }
    return [];
  }

  static Future<List<HQPickerResult>> bottomSheets({
    required BuildContext context,
    required final int maxCount,
    required final HQPickerRequestType requestType,
    HQPickerConfig config = const HQPickerConfig(),
    final Key? key,
    final String confirmText = 'Send',
    final String textEmptyList = 'No albums found.',
    final Color? confirmButtonColor,
    final Color confirmTextColor = Colors.black,
    final Color? backgroundColor,
    final Color? textEmptyListColor,
    final Color? backgroundSnackBarColor,
    final Color? dropdownColor,
    final Widget iconCamera = const Icon(Icons.camera, color: Colors.black),
    final TextStyle textStyleDropdown = const TextStyle(
      fontSize: 18,
      color: Colors.black,
    ),
    HQPickerCameraImageSettings? cameraImageSettings,
  }) async {
    final result = await showModalBottomSheet<List<AssetEntity>>(
      context: context,
      builder: (BuildContext context) {
        return HQPickerBottomSheets(
          maxCount: maxCount,
          requestType: requestType,
          backgroundColor: backgroundColor,
          backgroundSnackBarColor: backgroundSnackBarColor,
          confirmButtonColor: confirmButtonColor,
          confirmText: confirmText,
          confirmTextColor: confirmTextColor,
          key: key,
          textEmptyList: textEmptyList,
          textEmptyListColor: textEmptyListColor,
          dropdownColor: dropdownColor,
          iconCamera: iconCamera,
          textStyleDropdown: textStyleDropdown,
          cameraImageSettings: cameraImageSettings,
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      if (!context.mounted) return [];
      return await _processAssets(context, result, config);
    }
    return [];
  }

  static Future<List<HQPickerResult>> scaffoldBottomSheet({
    required BuildContext context,
    required int maxCount,
    required HQPickerRequestType requestType,
    HQPickerConfig config = const HQPickerConfig(),
    String confirmText = 'Send',
    String textEmptyList = 'No albums found.',
    Color? confirmButtonColor,
    Color confirmTextColor = Colors.black,
    Color? backgroundColor,
    Color? textEmptyListColor,
    Color? backgroundSnackBarColor,
    HQPickerCameraImageSettings? cameraImageSettings,
  }) async {
    final result = await showModalBottomSheet<List<AssetEntity>>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return HQPickerScaffoldBottomSheet(
          maxCount: maxCount,
          requestType: requestType,
          confirmText: confirmText,
          textEmptyList: textEmptyList,
          confirmButtonColor: confirmButtonColor,
          confirmTextColor: confirmTextColor,
          backgroundColor: backgroundColor,
          textEmptyListColor: textEmptyListColor,
          backgroundSnackBarColor: backgroundSnackBarColor,
          cameraImageSettings: cameraImageSettings,
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      if (!context.mounted) return [];
      return await _processAssets(context, result, config);
    }
    return [];
  }

  static Future<List<HQPickerResult>> bottomSheetImageSelector({
    required BuildContext context,
    required int maxCount,
    required HQPickerRequestType requestType,
    HQPickerConfig config = const HQPickerConfig(),
    String confirmText = 'Send',
    String textEmptyList = 'No albums found.',
    Color? confirmButtonColor,
    Color confirmTextColor = Colors.black,
    final Color? backgroundColor,
    final Color? textEmptyListColor,
    final Color? backgroundSnackBarColor,
    final Color? dropdownColor,
    final TextStyle textStyleDropdown = const TextStyle(
      fontSize: 18,
      color: Colors.black,
    ),
    final Widget iconCamera = const Icon(Icons.camera, color: Colors.black),
    final Widget? loading,
    HQPickerCameraImageSettings? cameraImageSettings,
  }) async {
    final result = await showModalBottomSheet<List<AssetEntity>>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return HQPickerBottomSheetImageSelector(
          maxCount: maxCount,
          requestType: requestType,
          confirmText: confirmText,
          backgroundColor: backgroundColor,
          backgroundSnackBarColor: backgroundSnackBarColor,
          confirmButtonColor: confirmButtonColor,
          confirmTextColor: confirmTextColor,
          textEmptyList: textEmptyList,
          textEmptyListColor: textEmptyListColor,
          textStyleDropdown: textStyleDropdown,
          dropdownColor: dropdownColor,
          cameraImageSettings: cameraImageSettings,
          iconCamera: iconCamera,
          loading: loading,
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      if (!context.mounted) return [];
      return await _processAssets(context, result, config);
    }
    return [];
  }

  /// Displays the Telegram-style sliding media sheet modally.
  static Future<List<HQPickerResult>> telegram({
    required BuildContext context,
    required int maxCount,
    HQPickerRequestType requestType = HQPickerRequestType.all,
    HQPickerConfig config = const HQPickerConfig(),
    bool isRealCameraView = false,
    Color? primeryColor,
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
          primeryColor: primeryColor ?? const Color(0xFF2C2C2C),
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

      case HQPickerShape.custom:
        return await customPicker(
          context: context,
          maxCount: maxCount,
          requestType: requestType,
          config: config,
        );

      case HQPickerShape.bottomSheet:
        return await bottomSheets(
          context: context,
          maxCount: maxCount,
          requestType: requestType,
          config: config,
        );

      case HQPickerShape.scaffoldBottomSheet:
        return await scaffoldBottomSheet(
          context: context,
          maxCount: maxCount,
          requestType: requestType,
          config: config,
        );

      case HQPickerShape.bottomSheetImageSelector:
        return await bottomSheetImageSelector(
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
        return await HQPickerFilePicker.pickDocument(
          context: context,
          shape: shape,
          allowedExtensions: allowedExtensions,
          maxCount: maxCount,
          config: config,
        );

      case HQPickerShape.directory:
        return await HQPickerFilePicker.pickDirectory(
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
    return await HQPickerFilePicker.pickDocument(
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
    return await HQPickerFilePicker.pickDirectory(
      context: context,
      shape: shape,
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
          appbarColor: appbarColor,
          backBottomColor: backBottomColor,
          iconCameraColor: iconCameraColor,
          iconGalleryColor: iconGalleryColor,
          iconSelectedListAlbumColor: iconSelectedListAlbumColor,
          textSelectedListAssetColor: textSelectedListAssetColor,
          backgroundDropDownColor: backgroundDropDownColor,
          nullColorText: nullColorText,
          textColor: textColor,
          confirmText: confirmText,
          confirmTextColor: confirmTextColor,
          backgroundColor: backgroundColor,
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

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedImageFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: widget.cameraImageSettings?.imageQuality,
        preferredCameraDevice:
            widget.cameraImageSettings?.preferredCameraDevice ?? CameraDevice.rear,
        maxWidth: widget.cameraImageSettings?.maxWidth,
        maxHeight: widget.cameraImageSettings?.maxHeight,
      );

      if (pickedImageFile != null) {
        final imageFile = File(pickedImageFile.path);
        _bloc.add(SetCapturedImageEvent(imageFile));

        bool isSaved = await FlutterSaver.saveImageAndroid(fileImage: imageFile);
        debugPrint('Image saved: $isSaved');

        if (isSaved) {
          _bloc.add(LoadAlbumsEvent(requestType: widget.requestType, fetchFileCounts: false));
        } else {
          debugPrint('Error: Image was not saved.');
        }
      } else {
        debugPrint('Image selection cancelled.');
      }
    } on PlatformException catch (error) {
      debugPrint('PlatformException: $error');
    } catch (error) {
      debugPrint('Error picking image: $error');
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
          backgroundColor: widget.backgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: widget.appbarColor,
            leading: const BackButton(color: Colors.white),
            centerTitle: true,
            title: widget.title,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: BlocBuilder<HQPickerBloc, HQPickerState>(
                  builder: (context, state) {
                    return InkResponse(
                      child: Text(
                        widget.confirmText,
                        style: TextStyle(color: widget.confirmTextColor),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color.fromARGB(255, 39, 36, 36),
                              margin: const EdgeInsets.all(15.0),
                              behavior: SnackBarBehavior.floating,
                              shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              content: const Text('No image selected'),
                            ),
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
                                    return const Center(
                                      child: Icon(Icons.error, color: Colors.red),
                                    );
                                  },
                                ),
                              ),
                              if (state.selectedEntity!.type == AssetType.video)
                                const Positioned.fill(
                                  child: Center(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 50.0,
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
                                              ? 'Gallery'
                                              : state.selectedAlbum!.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20.0,
                                            color: widget.textSelectedListAssetColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5.0),
                                          child: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: widget.iconSelectedListAlbumColor,
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
                                icon: Icon(
                                  state.isMultiple ? Icons.add_a_photo_outlined : Icons.add_a_photo,
                                  color: widget.iconGalleryColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await pickImage(ImageSource.camera);
                                },
                                icon: Icon(
                                  Icons.camera,
                                  color: widget.iconCameraColor,
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
                                          style: TextStyle(
                                            color: widget.nullColorText,
                                          ),
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
                album.name == 'Recent' ? 'Gallery' : album.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget assetWidget(AssetEntity assetEntity, HQPickerState state) {
    final isSelected = state.selectedAssetList.contains(assetEntity);
    return GestureDetector(
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
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ),
          if (assetEntity.type == AssetType.video)
            const Positioned.fill(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.video_library_outlined, color: Colors.red),
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
                        color: isSelected ? Colors.blue : Colors.white12,
                        shape: BoxShape.circle,
                        border: Border.all(width: 1.5, color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          isSelected ? '${state.selectedAssetList.indexOf(assetEntity) + 1}' : '',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.transparent,
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
