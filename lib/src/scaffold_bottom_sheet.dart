// ignore_for_file: unnecessary_import

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hq_picker/hq_picker.dart';
import 'package:hq_picker/src/widget/global/camera_image_setting.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// A stateful widget picker that displays a bottom sheet.
///
/// Example:
/// ```dart
/// HQPickerScaffoldBottomSheet(
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
///   cameraImageSettings: const HQPickerCameraImageSettings(
///     preferredCameraDevice: CameraDevice.rear,
///     imageQuality: 50,
///   ),
/// )
/// ```
///
class HQPickerScaffoldBottomSheet extends StatefulWidget {
  /// The maximum number of items that can be selected.
  final int maxCount;

  /// The type of request being made (e.g. photo, video, etc.).
  final HQPickerRequestType requestType;

  /// The text to display on the confirm button.
  /// Defaults to "Send" if not specified.
  final String confirmText;

  /// The text to display when the list is empty.
  /// Defaults to "No albums found." if not specified.
  final String textEmptyList;

  /// The color of the confirm button.
  final Color? confirmButtonColor;

  /// The color of the text on the confirm button.
  final Color confirmTextColor;

  /// The background color of the bottom sheet.
  final Color? backgroundColor;

  /// The color of the text when the list is empty.
  final Color? textEmptyListColor;

  /// The background color of the snack bar.
  final Color? backgroundSnackBarColor;

  /// The camera image settings to use when capturing images.
  final HQPickerCameraImageSettings? cameraImageSettings;

  /// The height of the bottom sheet as a fraction of the screen height.
  ///
  /// Defaults to 0.80 (80% of the screen height) if not specified.
  ///
  /// Use a value between 0.0 and 1.0.
  final double heightScaffoldBottomSheet;

  /// Constructs a new [HQPickerScaffoldBottomSheet] instance with the given properties.
  ///
  /// The [maxCount] and [requestType] properties are required.
  const HQPickerScaffoldBottomSheet({
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
    this.cameraImageSettings,
    this.heightScaffoldBottomSheet = 0.80,
  });

  @override
  State<HQPickerScaffoldBottomSheet> createState() =>
      _ScaffoldBottomSheetState();
}

class _ScaffoldBottomSheetState extends State<HQPickerScaffoldBottomSheet> {
  AssetPathEntity? selectedAlbum;
  AssetEntity? selectedEntity;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetsList = [];
  List<int> albumFileCounts = [];
  List<File?> albumFirstImages = [];
  List<AssetEntity> selectedAssetList = [];
  final HQPickerMediaServices1 mediaServices = HQPickerMediaServices1();
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAlbums();
    _startLoading();
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

  Future<void> _loadAlbums() async {
    List<int> fileCounts = [];
    List<File?> firstImages = [];
    try {
      List<AssetPathEntity> albums = await mediaServices.loadAlbums(
        widget.requestType,
      );

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
      // Handle error, show a message or take other appropriate action
      debugPrint('Error loading albums: $e');
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
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height * widget.heightScaffoldBottomSheet,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).primaryColorLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14.0),
          topRight: Radius.circular(14.0),
        ),
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
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
                          dropdownColor: Theme.of(context).cardColor,
                          value: selectedAlbum,
                          onChanged: (AssetPathEntity? value) {
                            setState(() {
                              selectedAlbum = value;
                            });
                            if (value != null) loadAssets(value);
                          },
                          items: albumList
                              .asMap()
                              .entries
                              .map<DropdownMenuItem<AssetPathEntity>>((entry) {
                                int index = entry.key;
                                AssetPathEntity album = entry.value;
                                return DropdownMenuItem<AssetPathEntity>(
                                  value: album,
                                  child: Row(
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
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        album.name == "Recent"
                                            ? "All"
                                            : album.name,
                                        style: TextStyle(
                                          fontSize: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge!.fontSize,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${albumFileCounts[index]})',
                                        style: TextStyle(
                                          fontSize: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge!.fontSize,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          try {
                            await pickImageCamera(ImageSource.camera);
                          } catch (e) {
                            debugPrint("Error picking image: $e");
                          }
                        },
                        icon: const Icon(Icons.camera, color: Colors.black),
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
                              ? LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.black,
                                  size: 75,
                                )
                              : Text(
                                  widget.textEmptyList,
                                  style: TextStyle(
                                    color:
                                        widget.textEmptyListColor ??
                                        Theme.of(context).primaryColor,
                                    fontSize: Theme.of(
                                      context,
                                    ).primaryTextTheme.headlineMedium!.fontSize,
                                  ),
                                ),
                        )
                      : GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: assetsList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 3,
                                mainAxisSpacing: 3,
                                mainAxisExtent: 100,
                              ),
                          itemBuilder: (context, index) {
                            if (index <= assetsList.length) {
                              AssetEntity assetEntity = assetsList[index];
                              return assetWidget(assetEntity, widget.maxCount);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                ),
              ),
              assetsList.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 1.0),
                      child: MaterialButton(
                        color:
                            widget.confirmButtonColor ??
                            Theme.of(context).primaryColorLight,
                        height: 55,
                        minWidth: size.width * 0.98,
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.merge(
                            BorderSide.none,
                            BorderSide.none,
                          ),
                        ),
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
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
            ],
          );
        },
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
      selectedAssetList.remove(assetEntity);
    } else if (selectedAssetList.length < maxCount) {
      selectedAssetList.add(assetEntity);
      selectedEntity = assetEntity;
      setState(() {});
    }
  }

  File? image;

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
          _loadAlbums();
        } else {
          debugPrint('Error: Image was not saved.');
        }
      });
    }
  }
}
