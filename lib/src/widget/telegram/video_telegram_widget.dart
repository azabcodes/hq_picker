import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hq_picker/src/telegram_media_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../bloc/hq_picker_bloc.dart';
import '../../bloc/hq_picker_event.dart';
import '../../bloc/hq_picker_state.dart';

class HQPickerVideoOnlyPage extends StatelessWidget {
  final HQPickerTelegramMediaPickers widget;
  final int maxCountPickFiles;
  final OnMediaPicked onFilesSelected;
  final ScrollController controller;
  final OverlayEntry overlayEntry;
  final VoidCallback toggleSheet;

  const HQPickerVideoOnlyPage({
    super.key,
    required this.maxCountPickFiles,
    required this.onFilesSelected,
    required this.controller,
    required this.overlayEntry,
    required this.toggleSheet,
    required this.widget,
  });

  void _sendSelectedFiles(BuildContext context, HQPickerState state) {
    onFilesSelected(state.selectedAssetList, null);
    toggleSheet();
  }

  void _toggleSelection(BuildContext context, AssetEntity assetEntity) {
    context.read<HQPickerBloc>().add(ToggleAssetSelectionEvent(assetEntity, maxCountPickFiles));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HQPickerBloc, HQPickerState>(
      builder: (context, state) {
        final videoAssets = state.assetsList.where((assetEntity) {
          return assetEntity.type == AssetType.video;
        }).toList();

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: videoAssets.isEmpty
                  ? Center(
                      child: Text(
                        widget.textEmptyListVideo,
                        style: widget.textStyleEmptyListText,
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
                                  controller: controller,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: videoAssets.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 3,
                                    mainAxisSpacing: 3,
                                    mainAxisExtent: 115,
                                  ),
                                  itemBuilder: (context, index) {
                                    AssetEntity assetEntity = videoAssets[index];
                                    return assetWidget(context, assetEntity, state);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (state.selectedAssetList.isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.10,
                right: 30,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    InkResponse(
                      onTap: () {
                        _sendSelectedFiles(context, state);
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(Icons.send, color: theme.colorScheme.onPrimary),
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
                          border: Border.all(color: Colors.black, width: 2.0),
                        ),
                        child: Text(
                          '${state.selectedAssetList.length}',
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget assetWidget(BuildContext context, AssetEntity assetEntity, HQPickerState state) {
    bool isSelected = state.selectedAssetList.contains(assetEntity);
    return GestureDetector(
      onTap: () {
        _toggleSelection(context, assetEntity);
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
  }
}
