import 'package:flutter/material.dart';
import 'package:hq_picker/src/telegram_media_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class HQPickerVideoOnlyPage extends StatefulWidget {
  /// The parent widget that manages media pickers.
  final HQPickerTelegramMediaPickers widget;

  /// The maximum number of video files that can be selected.
  final int maxCountPickFiles;

  /// Callback function triggered when video files are selected.
  final OnMediaPicked onFilesSelected;

  /// The scroll controller for handling the scrolling behavior.
  final ScrollController controller;

  /// The list of available video assets.
  final List<AssetEntity> assetsList;

  /// The currently selected album (optional).
  final AssetPathEntity? selectedAlbum;

  /// The currently selected video entity (optional).
  final AssetEntity? selectedEntity;

  /// The overlay entry used for displaying the widget as an overlay.
  final OverlayEntry overlayEntry;

  /// Callback function to toggle the visibility of the bottom sheet.
  final VoidCallback toggleSheet;

  /// Constructor for the HQPickerVideoOnlyPage class.

  const HQPickerVideoOnlyPage({
    super.key,
    required this.maxCountPickFiles,
    required this.onFilesSelected,
    required this.controller,
    required this.assetsList,
    required this.selectedAlbum,
    required this.selectedEntity,
    required this.overlayEntry,
    required this.toggleSheet,
    required this.widget,
  });

  @override
  State<HQPickerVideoOnlyPage> createState() => _VideoOnlyPageState();
}

class _VideoOnlyPageState extends State<HQPickerVideoOnlyPage> {
  final ValueNotifier<List<AssetEntity>> selectedAssetListNotifier =
      ValueNotifier<List<AssetEntity>>([]);
  List<AssetEntity> selectedAssetList = [];

  void _sendSelectedFiles() {
    widget.onFilesSelected(selectedAssetList, null);
    setState(() {});
  }

  void _toggleSelection(AssetEntity assetEntity) {
    setState(() {
      if (selectedAssetList.contains(assetEntity)) {
        selectedAssetList.remove(assetEntity);
      } else if (selectedAssetList.length < widget.maxCountPickFiles) {
        selectedAssetList.add(assetEntity);
      }
    });
    selectedAssetListNotifier.value = List.from(selectedAssetList);
  }

  @override
  Widget build(BuildContext context) {
    final videoAssets = widget.assetsList.where((assetEntity) {
      return assetEntity.type == AssetType.video;
    }).toList();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
          ),
          child: videoAssets.isEmpty
              ? Center(
                  child: Text(
                    widget.widget.textEmptyListVideo,
                    style: widget.widget.textStyleEmptyListText,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 15, right: 10, left: 10),
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
                              itemCount: videoAssets.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 3,
                                    mainAxisSpacing: 3,
                                    mainAxisExtent: 115,
                                  ),
                              itemBuilder: (context, index) {
                                AssetEntity assetEntity = videoAssets[index];
                                return assetWidget(
                                  assetEntity,
                                  widget.widget.maxCountPickMedia,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
            _toggleSelection(assetEntity);
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
    selectedAssetListNotifier.value = List.from(selectedAssetList);
  }
}
