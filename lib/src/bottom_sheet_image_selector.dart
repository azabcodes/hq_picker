// ignore_for_file: override_on_non_overriding_member

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hq_picker/src/tools/media_services.dart';
import 'package:hq_picker/src/widget/global/camera_image_setting.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

/// A stateful widget that displays a bottom sheet for selecting images.
///
/// Example:
/// ```dart
/// HQPickerBottomSheetImageSelector(
///   maxCount: 5,
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
///   iconCamera: const Icon(
///     Icons.camera,
///     color: Colors.black,
///   ),
///   loading: const CircularProgressIndicator(),
///   cameraImageSettings: const HQPickerCameraImageSettings(
///     imageQuality: 50,
///     preferredCameraDevice: CameraDevice.rear,
///     maxWidth: 300,
///     maxHeight: 300,
///   ),
///)
///)
class HQPickerBottomSheetImageSelector extends StatefulWidget {
  /// The maximum number of images that can be selected.
  final int maxCount;

  /// The type of request being made (e.g. photo, video, etc.).
  final HQPickerRequestType requestType;

  /// The text to display on the confirm button.
  final String confirmText;

  /// The text to display when the list of images is empty.
  final String textEmptyList;

  /// The color of the confirm button.
  final Color? confirmButtonColor;

  /// The color of the text on the confirm button.
  final Color confirmTextColor;

  /// The background color of the bottom sheet.
  final Color? backgroundColor;

  /// The color of the text when the list of images is empty.
  final Color? textEmptyListColor;

  /// The background color of the snack bar.
  final Color? backgroundSnackBarColor;

  /// The color of the dropdown menu.
  final Color? dropdownColor;

  /// The text style of the dropdown menu.
  final TextStyle textStyleDropdown;

  /// The icon to display for the camera button.
  final Widget iconCamera;

  /// The loading indicator to display while images are being loaded.
  final Widget? loading;

  /// The camera image settings to use when capturing images.
  final HQPickerCameraImageSettings? cameraImageSettings;
  const HQPickerBottomSheetImageSelector({
    super.key,
    required this.maxCount,
    required this.requestType,
    this.confirmText = "Send",
    this.textEmptyList = "No albums found.",
    this.confirmTextColor = Colors.black,
    this.backgroundColor,
    this.confirmButtonColor,
    this.textEmptyListColor,
    this.backgroundSnackBarColor,
    this.dropdownColor,
    this.cameraImageSettings,
    this.iconCamera = const Icon(Icons.camera, color: Colors.black),
    this.textStyleDropdown = const TextStyle(fontSize: 18, color: Colors.black),
    this.loading,
  });

  @override
  State<HQPickerBottomSheetImageSelector> createState() =>
      _BottomSheetImageSelectorState();
}

class _BottomSheetImageSelectorState
    extends State<HQPickerBottomSheetImageSelector>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<File?> imageFiles = [];

  AssetPathEntity? selectedAlbum;
  List<AssetEntity> selectedAssetList = [];
  AssetEntity? selectedEntity;

  List<AssetPathEntity> albumList = [];

  List<AssetEntity> assetsList = [];

  File? image;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _startLoading();
    _loadAlbum();
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
    return await HQPickerMediaServicesBottomSheetImageSelector.loadAlbums(
      widget.requestType,
    );
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
      final assets =
          await HQPickerMediaServicesBottomSheetImageSelector.loadAssets(
            selectedAlbum!,
          );
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
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.95,
      child: Scaffold(
        backgroundColor: widget.backgroundColor ?? Colors.grey.shade300,
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () {
                if (selectedAssetList.isNotEmpty) {
                  Navigator.pop(context, selectedAssetList);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor:
                          widget.backgroundSnackBarColor ??
                          Theme.of(context).primaryColor,
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
              child: Text(
                widget.confirmText,
                style: TextStyle(
                  color: widget.confirmTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SizedBox(
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
        ),
        bottomSheet: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                SizedBox(
                  height: 50.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        if (selectedAlbum != null)
                          DropdownButton<AssetPathEntity>(
                            underline: const SizedBox.shrink(),
                            icon: const SizedBox.shrink(),
                            dropdownColor:
                                widget.dropdownColor ??
                                Theme.of(context).cardColor,
                            value: selectedAlbum,
                            onChanged: (AssetPathEntity? value) {
                              setState(() {
                                selectedAlbum = value;
                              });

                              // Load the assets for the selected album.
                              HQPickerMediaServicesBottomSheetImageSelector.loadAssets(
                                selectedAlbum!,
                              ).then((value) {
                                setState(() {
                                  assetsList = value;
                                });
                              });
                            },
                            items: albumList
                                .map<DropdownMenuItem<AssetPathEntity>>((
                                  AssetPathEntity album,
                                ) {
                                  return DropdownMenuItem<AssetPathEntity>(
                                    value: album,
                                    child: Text(
                                      album.name == "Recent"
                                          ? "All"
                                          : album.name,
                                      style: widget.textStyleDropdown,
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => pickImageCamera(ImageSource.camera),
                          icon: widget.iconCamera,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: assetsList.isEmpty
                        ? Center(
                            child: isLoading
                                ? widget.loading ??
                                      const CircularProgressIndicator.adaptive()
                                : Text(
                                    widget.textEmptyList,
                                    style: TextStyle(
                                      color:
                                          widget.textEmptyListColor ??
                                          Theme.of(context).primaryColor,
                                      fontSize: Theme.of(context)
                                          .primaryTextTheme
                                          .headlineMedium!
                                          .fontSize,
                                    ),
                                  ),
                          )
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: assetsList.reversed.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 3,
                                  mainAxisSpacing: 3,
                                  mainAxisExtent: 100,
                                  childAspectRatio: 5.0,
                                ),
                            itemBuilder: (context, index) {
                              if (index <= assetsList.length) {
                                AssetEntity assetEntity = assetsList[index];
                                return assetWidget(
                                  assetEntity,
                                  widget.maxCount,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget assetWidget(AssetEntity assetEntity, int maxCount) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEntity = assetEntity;
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
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedAsset(assetEntity: assetEntity, maxCount: maxCount);
                });
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
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "${selectedAssetList.indexOf(assetEntity) + 1}",
                        style: TextStyle(
                          color: selectedAssetList.contains(assetEntity) == true
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

  void selectedAsset({
    required AssetEntity assetEntity,
    required int maxCount,
  }) {
    if (selectedAssetList.contains(assetEntity)) {
      setState(() {
        selectedAssetList.remove(assetEntity);
      });
    } else if (selectedAssetList.length < maxCount) {
      setState(() {
        selectedAssetList.add(assetEntity);
      });
    }
  }

  Future<void> pickImageCamera(ImageSource source) async {
    final myFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: widget.cameraImageSettings?.imageQuality,
      preferredCameraDevice: widget.cameraImageSettings!.preferredCameraDevice,
      maxWidth: widget.cameraImageSettings!.maxWidth,
      maxHeight: widget.cameraImageSettings!.maxHeight,
    );

    bool isSaved = false;
    if (myFile != null) {
      File image = File(myFile.path);
      if (Platform.isAndroid) {
        isSaved = await FlutterSaver.saveImageAndroid(fileImage: image);
      } else {
        isSaved = await FlutterSaver.saveImageIos(fileImage: image);
      }

      debugPrint("Image saved: $isSaved");

      setState(() {
        if (isSaved) {
          _loadAlbum();
        } else {
          debugPrint('Error: Image was not saved.');
        }
      });
    }
  }
}
