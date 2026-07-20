// ignore_for_file: unnecessary_import

library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hq_picker/src/bottom_sheet.dart';
import 'package:hq_picker/src/bottom_sheet_image_selector.dart';
import 'package:hq_picker/src/custom_picker.dart';
import 'package:hq_picker/src/scaffold_bottom_sheet.dart';
import 'package:hq_picker/src/tools/media_services.dart';
import 'package:hq_picker/src/widget/global/camera_image_setting.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

export 'package:hq_picker/src/custom_picker.dart';
export 'package:hq_picker/src/telegram_media_picker.dart';
export 'package:hq_picker/src/tools/media_services.dart';
export 'package:hq_picker/src/widget/global/camera_image_setting.dart';
export 'package:photo_manager/photo_manager.dart';
export 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
export 'package:hq_picker/src/file_picker_service.dart';

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

  /// Constructs a new [HQPicker] instance with the given properties.
  ///
  /// The [maxCount] and [requestType] properties are required.
  const HQPicker({
    required this.maxCount,
    required this.requestType,
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

  static Future<List<AssetEntity>> customPicker({
    required BuildContext context,
    required int maxCount,
    required HQPickerRequestType requestType,
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
      return result;
    }
    return [];
  }

  static Future<List<AssetEntity>> bottomSheets({
    required BuildContext context,
    required final int maxCount,
    required final HQPickerRequestType requestType,
    final Key? key,
    final String confirmText = "Send",
    final String textEmptyList = "No albums found.",
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
      return result;
    }

    return [];
  }

  static Future<List<AssetEntity>> scaffoldBottomSheet({
    required BuildContext context,
    required int maxCount,
    required HQPickerRequestType requestType,
    String confirmText = "Send",
    String textEmptyList = "No albums found.",
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
      return result;
    }

    return [];
  }

  static Future<List<AssetEntity>> bottomSheetImageSelector({
    required BuildContext context,
    required int maxCount,
    required HQPickerRequestType requestType,
    String confirmText = "Send",
    String textEmptyList = "No albums found.",
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
      return result;
    }

    return [];
  }

  @override
  State<HQPicker> createState() => _HQPickerState();

  Future<List<AssetEntity>> instagram(BuildContext context) async {
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
      return result;
    }
    return [];
  }
}

class _HQPickerState extends State<HQPicker>
    with AutomaticKeepAliveClientMixin {
  AssetEntity? selectedEntity;
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetsList = [];
  List<AssetEntity> selectedAssetList = [];
  bool isMultiple = false;
  bool isLoding = true;

  File? image;

  @override
  void initState() {
    super.initState();
    _startLoading();
    _loadAlbum();
  }

  @override
  void didUpdateWidget(covariant HQPicker oldWidget) {
    _startLoading();
    _loadAlbum();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _startLoading();
    _loadAlbum();
    super.didChangeDependencies();
  }

  Future<void> _loadAlbum() async {
    try {
      final albums = await _fetchAlbums();
      await _updateAlbums(albums);
      if (albums.isNotEmpty) {
        await _loadAssetsForSelectedAlbum();
      }
    } catch (error) {
      _handleError(error);
    }
  }

  Future<List<AssetPathEntity>> _fetchAlbums() async {
    return await HQPickerMediaServices.loadAlbums(widget.requestType);
  }

  Future<void> _updateAlbums(List<AssetPathEntity> albums) async {
    setState(() {
      albumList = albums;
      if (albums.isNotEmpty) {
        selectedAlbum = albums[0];
      }
    });
  }

  Future<void> _loadAssetsForSelectedAlbum() async {
    if (selectedAlbum != null) {
      final assets = await HQPickerMediaServices.loadAssets(selectedAlbum!);
      _updateAssets(assets);
    }
  }

  void _updateAssets(List<AssetEntity> assets) {
    setState(() {
      assetsList = assets;
      if (assets.isNotEmpty) {
        selectedEntity = assets[0];
      }
    });
  }

  void _handleError(dynamic error) {
    debugPrint('Error loading albums: $error');
  }

  void _startLoading() {
    setState(() {
      isLoding = true;
    });
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          isLoding = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return SafeArea(
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
              child: InkResponse(
                child: Text(
                  widget.confirmText,
                  style: TextStyle(color: widget.confirmTextColor),
                ),
                onTap: () {
                  if (selectedAssetList.isEmpty && selectedEntity != null) {
                    selectedAssetList = [selectedEntity!];
                  }

                  if (selectedAssetList.isNotEmpty) {
                    Navigator.pop(context, selectedAssetList);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color.fromARGB(255, 39, 36, 36),
                        margin: const EdgeInsets.all(15.0),
                        behavior: SnackBarBehavior.floating,
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        content: const Text("No image selected"),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: size.height * 0.40,
              child: image != null
                  ? Image.file(
                      fit: BoxFit.cover,
                      height: size.height,
                      width: size.width,
                      File(image!.path),
                    )
                  : (selectedEntity == null)
                  ? const SizedBox.shrink()
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: AssetEntityImage(
                            selectedEntity!,
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
                        if (selectedEntity!.type == AssetType.video)
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
                        if (selectedAlbum != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: GestureDetector(
                              onTap: () {
                                album(size.height, context);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    selectedAlbum!.name == "Recent"
                                        ? "Gallery"
                                        : selectedAlbum!.name,
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
                            setState(() {
                              isMultiple = isMultiple == true ? false : true;
                              selectedAssetList = [];
                            });
                          },
                          icon: Icon(
                            isMultiple == true
                                ? Icons.add_a_photo_outlined
                                : Icons.add_a_photo,
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
                    child: assetsList.isEmpty
                        ? Center(
                            child: isLoding
                                ? widget.loading ??
                                      const CircularProgressIndicator.adaptive()
                                : Text(
                                    widget.textEmptyList,
                                    style: TextStyle(
                                      color: widget.nullColorText,
                                    ),
                                  ),
                          )
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 1,
                                  crossAxisSpacing: 1,
                                ),
                            itemCount: assetsList.length,
                            itemBuilder: (context, index) {
                              if (index < assetsList.length) {
                                AssetEntity assetEntity = assetsList[index];
                                return assetWidget(assetEntity);
                              } else {
                                return Container(); // Return an empty container if the index is out of bounds.
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void album(double height, BuildContext contContext) {
    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 39, 36, 36),
      context: contContext,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      builder: (context) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: albumList.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                setState(() {
                  selectedAlbum = albumList[index];
                  HQPickerMediaServices.loadAssets(selectedAlbum!).then((
                    value,
                  ) {
                    setState(() {
                      assetsList = value;
                      selectedEntity = assetsList[0];
                    });
                  });
                });
                Navigator.pop(context);
              },
              title: Text(
                albumList[index].name == "Recent"
                    ? "Gallery"
                    : albumList[index].name,
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

  Widget assetWidget(AssetEntity assetEntity) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEntity = assetEntity;
          if (!isMultiple) {
            selectedAssetList = [assetEntity];
          }
        });
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
              color: assetEntity == selectedEntity
                  ? Colors.white60
                  : Colors.transparent,
            ),
          ),
          if (isMultiple == true)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  selectedAsset(assetEntity: assetEntity);
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedAssetList.contains(assetEntity) == true
                            ? Colors.blue
                            : Colors.white12,
                        shape: BoxShape.circle,
                        border: Border.all(width: 1.5, color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${selectedAssetList.indexOf(assetEntity) + 1}",
                          style: TextStyle(
                            color:
                                selectedAssetList.contains(assetEntity) == true
                                ? Colors.white
                                : Colors.transparent,
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

  void selectedAsset({required AssetEntity assetEntity}) {
    if (selectedAssetList.contains(assetEntity)) {
      setState(() {
        selectedAssetList.remove(assetEntity);
      });
    } else if (selectedAssetList.length < widget.maxCount) {
      setState(() {
        selectedAssetList.add(assetEntity);
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedImageFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: widget.cameraImageSettings?.imageQuality,
        preferredCameraDevice:
            widget.cameraImageSettings!.preferredCameraDevice,
        maxWidth: widget.cameraImageSettings!.maxWidth,
        maxHeight: widget.cameraImageSettings!.maxHeight,
      );

      if (pickedImageFile != null) {
        final imageFile = File(pickedImageFile.path);

        setState(() async {
          image = imageFile;

          bool isSaved = await FlutterSaver.saveImageAndroid(fileImage: image);
          debugPrint("Image saved: $isSaved");

          if (isSaved) {
            _loadAlbum();
          } else {
            debugPrint('Error: Image was not saved.');
          }
        });
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
  bool get wantKeepAlive => true;
}
