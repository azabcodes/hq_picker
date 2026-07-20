// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:hq_picker/src/custom_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class HQPickerVideoWidget extends StatefulWidget {
  /// The size of the video widget.
  final Size size;

  /// The instance of HQPickerCustomPicker used within this widget.
  final HQPickerCustomPicker widget;

  /// The currently selected asset entity (can be null).
  AssetEntity? selectedEntity;

  /// The list of all available asset entities.
  final List<AssetEntity> assetsList;

  /// The list of selected asset entities.
  final List<AssetEntity> selectedAssetList;

  /// Indicates whether a loading process is in progress.
  bool loading;

  /// Constructor for the HQPickerVideoWidget class.
  HQPickerVideoWidget({
    super.key,
    required this.size,
    required this.widget,
    required this.assetsList,
    required this.selectedAssetList,
    required this.selectedEntity,
    required this.loading,
  });

  @override
  State<HQPickerVideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<HQPickerVideoWidget> {
  @override
  Widget build(BuildContext context) {
    final videoAssets = widget.assetsList
        .where((assetEntity) => assetEntity.type == AssetType.video)
        .toList();
    return SingleChildScrollView(
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: widget.widget.showOnlyVideo && videoAssets.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: widget.assetsList.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: widget.size.height * 0.4,
                            ),
                            child: Center(
                              child: widget.loading
                                  ? const CircularProgressIndicator.adaptive()
                                  : Text(
                                      widget.widget.textEmptyList,
                                      style: TextStyle(
                                        color: widget.widget.textEmptyListColor,
                                        fontSize: 20,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      )
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.assetsList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 3,
                              mainAxisSpacing: 3,
                              mainAxisExtent: 115,
                              childAspectRatio: 5.0,
                            ),
                        itemBuilder: (context, index) {
                          AssetEntity assetEntity = widget.assetsList[index];
                          return assetWidget(
                            assetEntity,
                            widget.widget.maxCount,
                          );
                        },
                      ),
              )
            : Center(
                child: Text(
                  widget.widget.textEmptyList,
                  style: const TextStyle(
                    color: Color(0xFF6A0DAD),
                    fontSize: 20,
                  ),
                ),
              ),
      ),
    );
  }

  Widget assetWidget(AssetEntity assetEntity, int maxCount) {
    bool isSelected = widget.selectedAssetList.contains(assetEntity);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            widget.selectedAssetList.remove(assetEntity);
          } else if (widget.selectedAssetList.length < maxCount) {
            widget.selectedAssetList.add(assetEntity);
          }
        });
      },
      child: Stack(
        children: [
          (assetEntity.type == AssetType.video)
              ? Positioned.fill(
                  child: AssetEntityImage(
                    assetEntity,
                    thumbnailSize: const ThumbnailSize.square(250),
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                )
              : Container(),
          const Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.video_library_outlined, color: Colors.red),
              ),
            ),
          ),
          if (isSelected)
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black54 : Colors.transparent,
                  border: Border.all(width: 8, color: Colors.white70),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 30),
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
    if (widget.selectedAssetList.contains(assetEntity)) {
      setState(() {
        widget.selectedAssetList.remove(assetEntity);
      });
    } else if (widget.selectedAssetList.length < maxCount) {
      setState(() {
        widget.selectedAssetList.add(assetEntity);
      });
    }
  }
}
