import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:hq_picker/src/telegram_media_picker.dart';
import 'package:hq_picker/src/widget/camera_preview_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../bloc/hq_picker_bloc.dart';
import '../../bloc/hq_picker_event.dart';
import '../../bloc/hq_picker_state.dart';

class HQPickerDefultBuilderWidget extends StatelessWidget {
  final HQPickerTelegramMediaPickers widget;
  final ScrollController controller;

  const HQPickerDefultBuilderWidget({
    super.key,
    required this.widget,
    required this.controller,
  });

  void _sendSelectedFiles(BuildContext context, HQPickerState state) {
    widget.onMediaPicked?.call(state.selectedAssetList, null);
    context.read<HQPickerBloc>().add(const ToggleSheetEvent());
  }

  Future<void> pickImageCamera(BuildContext context, ImageSource source) async {
    final myFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: widget.cameraImageSettings?.imageQuality,
      preferredCameraDevice: widget.cameraImageSettings?.preferredCameraDevice ?? CameraDevice.rear,
      maxWidth: widget.cameraImageSettings?.maxWidth,
      maxHeight: widget.cameraImageSettings?.maxHeight,
    );

    bool isSaved = false;
    if (myFile != null) {
      File image = File(myFile.path);
      if (Platform.isAndroid) {
        isSaved = await FlutterSaver.saveImageAndroid(fileImage: image);
      } else {
        isSaved = await FlutterSaver.saveImageIos(fileImage: image);
      }

      debugPrint('Image saved: $isSaved');

      if (isSaved) {
        if (context.mounted) {
          context.read<HQPickerBloc>().add(
            LoadAlbumsEvent(
              requestType: widget.requestType,
              fetchFileCounts: true,
            ),
          );
        }
      } else {
        debugPrint('Error: Image was not saved.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HQPickerBloc, HQPickerState>(
      builder: (context, state) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20.0),
                ),
              ),
              child: state.assetsList.isEmpty
                  ? Center(
                      child: state.status == HQPickerStatus.loading
                          ? widget.loading ?? const CircularProgressIndicator.adaptive()
                          : Text(
                              widget.textEmptyList,
                              style: TextStyle(
                                color:
                                    widget.textEmptyListColor ??
                                    Theme.of(context).colorScheme.onPrimary,
                                fontSize:
                                    Theme.of(context).primaryTextTheme.headlineMedium?.fontSize ??
                                    20,
                              ),
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
                                  itemCount: state.assetsList.length + 1,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 3,
                                    mainAxisSpacing: 3,
                                    mainAxisExtent: 115,
                                  ),
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      if (widget.isRealCameraView) {
                                        return HQPickerCameraPreviewWidget(
                                          pickImageCamera: (source) =>
                                              pickImageCamera(context, source),
                                        );
                                      } else {
                                        return HQPickerFackeCameraWidget(
                                          pickImageCamera: (source) =>
                                              pickImageCamera(context, source),
                                        );
                                      }
                                    } else {
                                      AssetEntity assetEntity = state.assetsList[index - 1];
                                      return assetWidget(
                                        context,
                                        assetEntity,
                                        widget.maxCountPickMedia,
                                        state,
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

  Widget assetWidget(
    BuildContext context,
    AssetEntity assetEntity,
    int maxCount,
    HQPickerState state,
  ) {
    bool isSelected = state.selectedAssetList.contains(assetEntity);
    return GestureDetector(
      onTap: () {
        context.read<HQPickerBloc>().add(ToggleAssetSelectionEvent(assetEntity, maxCount));
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
