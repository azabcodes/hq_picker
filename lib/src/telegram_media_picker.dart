// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hq_picker/src/tools/media_services.dart';
import 'package:hq_picker/src/tools/theme_generator.dart';
import 'package:hq_picker/src/widget/global/camera_image_setting.dart';
import 'package:hq_picker/src/widget/telegram/audio_telegram_widget.dart';
import 'package:hq_picker/src/widget/telegram/defult_builder_widget.dart';
import 'package:hq_picker/src/widget/telegram/file_device_widget.dart';
import 'package:hq_picker/src/widget/telegram/video_telegram_widget.dart';
import 'package:photo_manager/photo_manager.dart';

export 'package:hq_picker/src/widget/global/camera_image_setting.dart';

/// [theme] is the theme of the application.
late ThemeData theme;

/// The callback function to call when media files are picked.
typedef OnMediaPicked =
    void Function(List<AssetEntity>? assets, List<FileSystemEntity>? files);

/// A stateful widget that allows users to pick media files (images, videos, audio, files) from their device.
///
/// Example usage:
///
/// create global key
///
/// ```dart
/// GlobalKey<_TelegramMediaPickersState> _key = GlobalKey();
/// ```
///
/// create onTap function
/// ```dart
/// ElevatedButton(
///  onPressed: () {
///        _sheetKey.currentState?.toggleSheet(context);
///   },
/// child: const Text("Open Telegram Pickers"),
///),
/// ```
/// create widget body with global key
/// ```dart
/// HQPickerTelegramMediaPickers(
///   maxCountPickMedia: 5,
///   requestType: HQPickerRequestType.photo,
///   confirmText: "Send",
///   textEmptyList: "No albums found.",
///   confirmTextColor: Colors.black,
///   backgroundColor: Colors.grey.shade300,
///   confirmButtonColor: Colors.black,
///   textEmptyListColor: Colors.black,
///   backgroundSnackBarColor: Colors.black,
///   dropdownColor: Colors.black,
///   textStyleDropdown: const TextStyle(
///     fontSize: 18,
///     color: Colors.black,
///   ),
/// )
/// ```
///
///

class HQPickerTelegramMediaPickers extends StatefulWidget {
  /// The maximum number of media files that can be picked.
  final int maxCountPickMedia;

  /// The type of request being made (e.g. photo, video, etc.).
  final HQPickerRequestType requestType;

  /// Whether to use the real camera view or not.
  final bool isRealCameraView;

  /// The text to display when the list of videos is empty.
  final String textEmptyListVideo;

  /// The text to display when the list of images is empty.
  final String textEmptyList;

  /// The text to display when the list of files is empty.
  final String textEmptyListFile;

  /// The text to display when the list of audio files is empty.
  final String textEmptyListAudio;

  /// The text style of the empty list text.
  final TextStyle textStyleEmptyListText;

  /// The color of the confirm button.
  final Color? confirmButtonColor;

  /// The color of the text on the confirm button.
  final Color confirmTextColor;

  /// The background color of the widget.
  final Color? backgroundColor;

  /// The color of the text when the list is empty.
  final Color? textEmptyListColor;

  /// The background color of the snack bar.
  final Color? backgroundSnackBarColor;

  /// The color of the dropdown menu.
  final Color? dropdownColor;

  /// The primary color of the widget.
  final Color? primeryColor;

  /// The icon to display for the camera button.
  final Widget iconCamera;

  /// The loading indicator to display while media files are being loaded.
  final Widget? loading;

  /// The callback function to call when media files are picked.
  final OnMediaPicked? onMediaPicked;

  /// The maximum number of files that can be picked.
  final int maxCountPickFiles;

  /// The camera image settings to use when capturing images.
  final HQPickerCameraImageSettings? cameraImageSettings;
  const HQPickerTelegramMediaPickers({
    super.key,
    required this.maxCountPickMedia,
    this.requestType = HQPickerRequestType.all,
    this.isRealCameraView = true,
    this.textEmptyListVideo = "No video found.",
    this.textEmptyList = "No albums found.",
    this.textEmptyListFile = "No files found.",
    this.textEmptyListAudio = "No audio found.",
    this.confirmTextColor = Colors.black,
    this.backgroundColor,
    this.confirmButtonColor,
    this.textEmptyListColor,
    this.backgroundSnackBarColor,
    this.dropdownColor,
    this.primeryColor = const Color(0xFF2C2C2C),
    this.onMediaPicked,
    this.maxCountPickFiles = 5,
    this.cameraImageSettings,
    this.textStyleEmptyListText = const TextStyle(
      color: Colors.grey,
      fontSize: 18,
    ),
    this.iconCamera = const Icon(Icons.camera, color: Colors.black),
    this.loading,
  });

  @override
  State<HQPickerTelegramMediaPickers> createState() =>
      HQPickerTelegramMediaPickersState();
}

class HQPickerTelegramMediaPickersState
    extends State<HQPickerTelegramMediaPickers>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late Color primaryColor;

  bool isDraggableOpen = false;
  late DraggableScrollableController _controller;
  final ValueNotifier<double> _sizeNotifier = ValueNotifier<double>(0.5);
  final ValueNotifier<List<AssetEntity>> selectedAssetListNotifier =
      ValueNotifier<List<AssetEntity>>([]);
  OverlayEntry? _overlayEntry;

  AssetPathEntity? selectedAlbum;
  AssetEntity? selectedEntity;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetsList = [];
  List<int> albumFileCounts = [];
  List<File?> albumFirstImages = [];
  List<AssetEntity> selectedAssetList = [];
  final HQPickerMediaServicesBottomSheet mediaServices =
      HQPickerMediaServicesBottomSheet();
  bool isLoading = true;

  bool isVideo = false;
  bool isAudio = false;
  bool isFile = false;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
    loadAlbums();
    _startLoading();
    primaryColor = widget.primeryColor ?? const Color(0xFF2C2C2C);
    theme = HQPickerThemeGenerator.generateTheme(primaryColor: primaryColor);
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    selectedAssetListNotifier.dispose();
    _sizeNotifier.dispose();
    super.dispose();
  }

  void toggleSheet(BuildContext context) {
    if (isDraggableOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      isFile = false;
      isVideo = false;
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
    setState(() {
      isDraggableOpen = !isDraggableOpen;
    });
  }

  void _startLoading() {
    setState(() {
      isLoading = true;
    });
    // Shorten the delay and handle mounted condition properly
    Future.delayed(
      const Duration(seconds: 3), // Reduced delay for faster feedback
      () {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      },
    );
  }

  Future<void> loadAlbums({BuildContext? context}) async {
    try {
      final albums = await _fetchAlbums();
      final fileCountsAndFirstImages = await _fetchFileCountsAndFirstImages(
        albums,
      );
      _updateStateWithAlbums(albums, fileCountsAndFirstImages);
    } catch (e) {
      _handleError(context, e);
    }
  }

  Future<List<AssetPathEntity>> _fetchAlbums() async {
    return await mediaServices.loadAlbums(widget.requestType);
  }

  Future<Map<String, dynamic>> _fetchFileCountsAndFirstImages(
    List<AssetPathEntity> albums,
  ) async {
    List<int> fileCounts = [];
    List<File?> firstImages = [];

    for (var album in albums) {
      final assets = await mediaServices.loadAssets(album);
      fileCounts.add(assets.length);

      if (assets.isNotEmpty) {
        final file = await assets.first.file;
        firstImages.add(file);
      } else {
        firstImages.add(null);
      }
    }

    return {'fileCounts': fileCounts, 'firstImages': firstImages};
  }

  void _updateStateWithAlbums(
    List<AssetPathEntity> albums,
    Map<String, dynamic> fileCountsAndFirstImages,
  ) {
    setState(() {
      albumList = albums;
      albumFileCounts = fileCountsAndFirstImages['fileCounts'];
      albumFirstImages = fileCountsAndFirstImages['firstImages'];
      if (albums.isNotEmpty) {
        selectedAlbum = albums[0];
        loadAssets(albums[0]);
      }
    });
  }

  Future<void> loadAssets(AssetPathEntity album) async {
    try {
      final assets = await mediaServices.loadAssets(album);
      _updateStateWithAssets(assets);
    } catch (e) {
      debugPrint('Error loading assets: $e');
    }
  }

  void _updateStateWithAssets(List<AssetEntity> assets) {
    setState(() {
      selectedEntity = assets.isNotEmpty ? assets[0] : null;
      assetsList = assets;
    });
  }

  void _handleError(BuildContext? context, dynamic error) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading albums: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      debugPrint('Error loading albums: $error');
    }
  }

  /* Future<void> loadAlbums({BuildContext? context}) async {
    List<int> fileCounts = [];
    List<File?> firstImages = [];
    try {
      List<AssetPathEntity> albums = await mediaServices.loadAlbums(widget.requestType);

      for (var album in albums) {
        List<AssetEntity> assets = await mediaServices.loadAssets(album);
        fileCounts.add(assets.length);

        if (assets.isNotEmpty) {
          File? file = await assets.first.file;
          firstImages.add(file);
        } else {
          firstImages.add(null);
        }
      }

      setState(() {
        albumList = albums;
        albumFileCounts = fileCounts;
        albumFirstImages = firstImages;
        if (albums.isNotEmpty) {
          selectedAlbum = albums[0];
          loadAssets(albums[0]);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text('Error loading albums: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> loadAssets(AssetPathEntity album) async {
    try {
      List<AssetEntity> assets = await mediaServices.loadAssets(album);
      setState(() {
        selectedEntity = assets.isNotEmpty ? assets[0] : null;
        assetsList = assets;
      });
    } catch (e) {
      // Handle error, show a message or take other appropriate action
      debugPrint('Error loading assets: $e');
    }
  }*/

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  toggleSheet(context);
                },
                child: Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                      child: Container(
                        color: Colors.black.withValues(
                          alpha: 0.3,
                        ), // Semi-transparent background
                      ),
                    ),
                    SafeArea(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Builder(
                            builder: (context) {
                              return Stack(
                                children: [
                                  DraggableScrollableSheet(
                                    controller: _controller,
                                    initialChildSize: 0.5,
                                    minChildSize: 0.2,
                                    maxChildSize: 1.0,
                                    builder: (context, scrollController) {
                                      _controller.addListener(() {
                                        _sizeNotifier.value = _controller.size;
                                      });

                                      if (isFile) {
                                        return HQPickerFileListScreen(
                                          scrollController: scrollController,
                                          overlayEntry: _overlayEntry!,
                                          maxCountPickFiles:
                                              widget.maxCountPickFiles,
                                          textEmptyListFile:
                                              widget.textEmptyListFile,
                                          textStyleEmptyListText:
                                              widget.textStyleEmptyListText,
                                          toggleSheet: () {
                                            toggleSheet(context);
                                          },
                                          onFilesSelected:
                                              (assets, selectedFiles) {
                                                widget.onMediaPicked?.call(
                                                  null,
                                                  selectedFiles,
                                                );
                                                setState(() {});
                                              },
                                        );
                                      } else if (isVideo) {
                                        return HQPickerVideoOnlyPage(
                                          widget: widget,
                                          controller: scrollController,
                                          maxCountPickFiles:
                                              widget.maxCountPickFiles,
                                          overlayEntry: _overlayEntry!,
                                          assetsList: assetsList,
                                          selectedAlbum: selectedAlbum!,
                                          selectedEntity: selectedEntity,
                                          toggleSheet: () {
                                            toggleSheet(context);
                                          },
                                          onFilesSelected:
                                              (assets, selectedFiles) {
                                                widget.onMediaPicked?.call(
                                                  null,
                                                  selectedFiles,
                                                );
                                                setState(() {});
                                              },
                                        );
                                      } else if (isAudio) {
                                        return HQPickerAudioTelegramWidget(
                                          scrollController: scrollController,
                                          maxCountPickFiles:
                                              widget.maxCountPickFiles,
                                          overlayEntry: _overlayEntry!,
                                          textEmptyListAudio:
                                              widget.textEmptyListAudio,
                                          textStyleEmptyListText:
                                              widget.textStyleEmptyListText,
                                          toggleSheet: () {
                                            toggleSheet(context);
                                          },
                                          onFilesSelected:
                                              (assets, selectedFiles) {
                                                widget.onMediaPicked?.call(
                                                  null,
                                                  selectedFiles,
                                                );
                                                setState(() {});
                                              },
                                        );
                                      } else {
                                        return HQPickerDefultBuilderWidget(
                                          widget: widget,
                                          valueListenable: _sizeNotifier,
                                          toggleSheet: () {
                                            toggleSheet(context);
                                          },
                                          loadAlbums: loadAlbums,
                                          overlayEntry: _overlayEntry!,
                                          isLoading: isLoading,
                                          isRealCameraView:
                                              widget.isRealCameraView,
                                          assetsList: assetsList,
                                          controller: scrollController,
                                          albumFileCounts: albumFileCounts,
                                          albumFirstImages: albumFirstImages,
                                          albumList: albumList,
                                          selectedAlbum: selectedAlbum,
                                          selectedEntity: selectedEntity,
                                          onMediaPicked: (assets, files) {
                                            widget.onMediaPicked?.call(
                                              assets,
                                              null,
                                            );
                                            setState(() {});
                                          },
                                        );
                                      }
                                    },
                                  ),
                                  // App bar that appears when the sheet is near the top
                                  ValueListenableBuilder<double>(
                                    valueListenable: _sizeNotifier,
                                    builder: (context, size, child) {
                                      final showAppBar = size > 0.9;
                                      return Positioned(
                                        top: 0,
                                        right: 0,
                                        left: 0,
                                        child: Theme(
                                          data: theme,
                                          child: AnimatedOpacity(
                                            opacity: showAppBar ? 1.0 : 0.0,
                                            duration: const Duration(
                                              milliseconds: 400,
                                            ),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 400,
                                              ),
                                              height: showAppBar
                                                  ? MediaQuery.of(
                                                          context,
                                                        ).size.height *
                                                        0.075
                                                  : 0,
                                              color: theme.primaryColor,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 15.0,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        toggleSheet(context);
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .arrow_back_ios_new,
                                                        color: theme
                                                            .colorScheme
                                                            .onPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                    InkWell(
                                                      onTap: () {
                                                        album(context);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            selectedAlbum !=
                                                                        null &&
                                                                    selectedAlbum!
                                                                            .name ==
                                                                        "Recent"
                                                                ? "Gallery"
                                                                : selectedAlbum
                                                                          ?.name ??
                                                                      '',
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      22.0,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .keyboard_arrow_down_sharp,
                                                            color: theme
                                                                .colorScheme
                                                                .onPrimary,
                                                            size: 28,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Bottom bar
                                  ValueListenableBuilder<double>(
                                    valueListenable: _sizeNotifier,
                                    builder: (context, size, child) {
                                      final showBottomBar = size < 0.9;
                                      return Positioned(
                                        bottom: 0,
                                        right: 0,
                                        left: 0,
                                        child: AnimatedOpacity(
                                          opacity: showBottomBar ? 1.0 : 0.0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            height: showBottomBar
                                                ? MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      0.095
                                                : 0,
                                            color: theme.primaryColor,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 15.0,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          isFile = !isFile;
                                                        });
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            CupertinoIcons.doc,
                                                            color: theme
                                                                .colorScheme
                                                                .onPrimary,
                                                            size: 28,
                                                          ),
                                                          const SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            "File",
                                                            style: TextStyle(
                                                              color: theme
                                                                  .colorScheme
                                                                  .onPrimary,
                                                              fontSize: 14.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          isVideo = !isVideo;
                                                        });
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            CupertinoIcons.film,
                                                            color: theme
                                                                .colorScheme
                                                                .onPrimary,
                                                            size: 28,
                                                          ),
                                                          const SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            "Video",
                                                            style: TextStyle(
                                                              color: theme
                                                                  .colorScheme
                                                                  .onPrimary,
                                                              fontSize: 14.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          isAudio = !isAudio;
                                                        });
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            CupertinoIcons
                                                                .music_albums_fill,
                                                            color: theme
                                                                .colorScheme
                                                                .onPrimary,
                                                            size: 28,
                                                          ),
                                                          const SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            "Audio",
                                                            style: TextStyle(
                                                              color: theme
                                                                  .colorScheme
                                                                  .onPrimary,
                                                              fontSize: 14.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SizedBox.shrink();
  }

  void album(BuildContext contContext) {
    OverlayEntry? overlayEntry;
    ScrollController controller = ScrollController();
    overlayEntry = OverlayEntry(
      builder: (context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          overlayEntry?.remove();
        },
        child: GestureDetector(
          onTap: () {
            overlayEntry?.remove(); // Close the menu when tapping outside
          },
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  left: 25,
                  top: 50,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return GestureDetector(
                        onTap: () {
                          // Prevent closing the menu when tapping inside
                        },
                        child: Container(
                          width: 320,
                          height: MediaQuery.of(context).size.height * 0.85,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: ListView.builder(
                              controller: controller,
                              shrinkWrap: false,
                              physics: const BouncingScrollPhysics(),
                              itemCount: albumList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: () async {
                                    // Update selected album
                                    selectedAlbum = albumList[index];

                                    // Load assets for the selected album
                                    final assets =
                                        await HQPickerMediaServices.loadAssets(
                                          selectedAlbum!,
                                        );

                                    // Update the UI
                                    setState(() {
                                      assetsList = assets;
                                      selectedEntity = assetsList.isNotEmpty
                                          ? assetsList[0]
                                          : null;
                                    });

                                    // Notify the parent widget to rebuild
                                    if (contContext.mounted) {
                                      (contContext as Element).markNeedsBuild();
                                    }

                                    // Close the overlay
                                    overlayEntry?.remove();
                                  },
                                  title: Row(
                                    children: [
                                      if (albumFirstImages[index] != null)
                                        ImageFiltered(
                                          imageFilter: ImageFilter.blur(
                                            sigmaX: 1.0,
                                            sigmaY: 1.0,
                                          ),
                                          child: Image(
                                            fit: BoxFit.cover,
                                            image: FileImage(
                                              albumFirstImages[index]!,
                                            ),
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 15.0,
                                        ),
                                        child: Text(
                                          albumList[index].name == "Recent"
                                              ? "Gallery"
                                              : albumList[index].name,
                                          style: TextStyle(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${albumFileCounts[index]}',
                                        style: TextStyle(
                                          color: theme.primaryColorLight,
                                          fontWeight: FontWeight.w500,
                                          fontSize: theme
                                              .textTheme
                                              .bodySmall
                                              ?.fontSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Add the OverlayEntry to the current Overlay
    Overlay.of(contContext).insert(overlayEntry);
  }

  @override
  bool get wantKeepAlive => true;
}
