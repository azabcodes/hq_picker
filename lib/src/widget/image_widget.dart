// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:hq_picker/src/custom_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class HQPickerImageWidget extends StatefulWidget {
  /// The size of the image widget.
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

  /// Constructor for the HQPickerImageWidget class.

  HQPickerImageWidget({
    super.key,
    required this.size,
    required this.widget,
    required this.assetsList,
    required this.selectedAssetList,
    required this.selectedEntity,
    required this.loading,
  });

  @override
  State<HQPickerImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<HQPickerImageWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: SizedBox(
          width: widget.size.width,
          height: double.maxFinite,
          child: widget.widget.showOnlyImage
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: widget.assetsList.isEmpty
                      ? Center(
                          child: widget.loading
                              ? const CircularProgressIndicator.adaptive()
                              : Text(
                                  widget.widget.textEmptyList,
                                  style: TextStyle(
                                    color: widget.widget.textEmptyListColor,
                                    fontSize: 20,
                                  ),
                                ),
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
                    style: TextStyle(
                      color: widget.widget.textEmptyListColor,
                      fontSize: 20,
                    ),
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
          Positioned.fill(
            child: AssetEntityImage(
              assetEntity,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize.square(100),
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
