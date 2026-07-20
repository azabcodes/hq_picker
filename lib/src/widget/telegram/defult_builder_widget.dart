// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hq_picker/src/telegram_media_picker.dart';
import 'package:hq_picker/src/widget/camera_preview_widget.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class HQPickerDefultBuilderWidget extends StatefulWidget {
  HQPickerTelegramMediaPickers widget;
  ValueListenable<double> valueListenable;
  bool isLoading;

  ScrollController controller;
  List<AssetEntity> assetsList;
  AssetPathEntity? selectedAlbum;
  AssetEntity? selectedEntity;
  List<AssetPathEntity> albumList;

  List<int> albumFileCounts;
  List<File?> albumFirstImages;

  OnMediaPicked onMediaPicked;
  final OverlayEntry overlayEntry;

  final VoidCallback toggleSheet;
  final VoidCallback loadAlbums;
  final bool isRealCameraView;

  HQPickerDefultBuilderWidget({
    super.key,
    required this.widget,
    required this.valueListenable,
    required this.isLoading,
    required this.assetsList,
    required this.controller,
    required this.albumList,
    required this.albumFileCounts,
    required this.albumFirstImages,
    required this.selectedAlbum,
    required this.selectedEntity,
    required this.onMediaPicked,
    required this.toggleSheet,
    required this.overlayEntry,
    required this.loadAlbums,
    required this.isRealCameraView,
  });

  @override
  State<HQPickerDefultBuilderWidget> createState() =>
      _DefultBuilderWidgetState();
}

class _DefultBuilderWidgetState extends State<HQPickerDefultBuilderWidget>
    with AutomaticKeepAliveClientMixin {
  List<AssetEntity> selectedAssetList = [];
  final ValueNotifier<List<AssetEntity>> selectedAssetListNotifier =
      ValueNotifier<List<AssetEntity>>([]);

  void _sendSelectedFiles() {
    widget.onMediaPicked(selectedAssetList, null);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        ValueListenableBuilder<double>(
          valueListenable: widget.valueListenable,
          builder: (context, size, child) {
            return Container(
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20.0),
                ),
              ),
              child: widget.assetsList.isEmpty
                  ? Center(
                      child: widget.isLoading
                          ? widget.widget.loading ??
                                const CircularProgressIndicator.adaptive()
                          : Text(
                              widget.widget.textEmptyList,
                              style: TextStyle(
                                color:
                                    widget.widget.textEmptyListColor ??
                                    Theme.of(context).colorScheme.onPrimary,
                                fontSize: Theme.of(
                                  context,
                                ).primaryTextTheme.headlineMedium!.fontSize,
                              ),
                            ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                        right: 10,
                        left: 10,
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 7,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  controller: widget.controller,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: widget.assetsList.length + 1,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 3,
                                        mainAxisSpacing: 3,
                                        mainAxisExtent: 115,
                                      ),
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      if (widget.isRealCameraView) {
                                        return HQPickerCameraPreviewWidget(
                                          pickImageCamera: pickImageCamera,
                                        );
                                      } else {
                                        return HQPickerFackeCameraWidget(
                                          pickImageCamera: pickImageCamera,
                                        );
                                      }
                                    } else {
                                      AssetEntity assetEntity =
                                          widget.assetsList[index - 1];
                                      return assetWidget(
                                        assetEntity,
                                        widget.widget.maxCountPickMedia,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
        ValueListenableBuilder<List<AssetEntity>>(
          valueListenable: selectedAssetListNotifier,
          builder: (context, selectedAssetList, child) {
            return selectedAssetList.isNotEmpty
                ? Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.10,
                    right: 30,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        InkResponse(
                          onTap: () {
                            debugPrint(
                              'Selected files: ${selectedAssetList.length}',
                            );
                            _sendSelectedFiles();
                            widget.toggleSheet();
                          },
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.primary,
                            child: Icon(
                              Icons.send,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
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
                              border: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            child: Text(
                              '${selectedAssetList.length}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget assetWidget(AssetEntity assetEntity, int maxCount) {
    return ValueListenableBuilder<List<AssetEntity>>(
      valueListenable: selectedAssetListNotifier,
      builder: (context, selectedAssetList, child) {
        bool isSelected = selectedAssetList.contains(assetEntity);
        return GestureDetector(
          onTap: () {
            if (isSelected) {
              selectedAssetListNotifier.value = List.from(selectedAssetList)
                ..remove(assetEntity);
              setState(() {
                selectedAssetList.remove(assetEntity);
              });
            } else if (selectedAssetList.length < maxCount) {
              selectedAssetListNotifier.value = List.from(selectedAssetList)
                ..add(assetEntity);
              setState(() {
                selectedAssetList.add(assetEntity);
              });
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: AssetEntityImage(
                  assetEntity,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize.square(80),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      border: Border.all(width: 8, color: Colors.white70),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
      imageQuality: widget.widget.cameraImageSettings?.imageQuality,
      preferredCameraDevice:
          widget.widget.cameraImageSettings!.preferredCameraDevice,
      maxWidth: widget.widget.cameraImageSettings!.maxWidth,
      maxHeight: widget.widget.cameraImageSettings!.maxHeight,
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
          widget.loadAlbums();
        } else {
          debugPrint('Error: Image was not saved.');
        }
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
