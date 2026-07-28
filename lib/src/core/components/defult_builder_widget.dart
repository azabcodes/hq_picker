import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:hq_picker/src/core/bloc/hq_picker_state.dart';
import 'package:hq_picker/src/core/components/camera_preview_widget.dart';
import 'package:hq_picker/src/telegram/telegram_media_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../bloc/hq_picker_bloc.dart';
import '../bloc/hq_picker_event.dart';
import '../tools/media_services.dart';

class HQPickerDefultBuilderWidget extends StatefulWidget {
  final HQPickerTelegramMediaPickers widget;
  final ScrollController controller;

  const HQPickerDefultBuilderWidget({
    super.key,
    required this.widget,
    required this.controller,
  });

  @override
  State<HQPickerDefultBuilderWidget> createState() => _HQPickerDefultBuilderWidgetState();
}

class _HQPickerDefultBuilderWidgetState extends State<HQPickerDefultBuilderWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _sendSelectedFiles(BuildContext context, HQPickerState state) {
    widget.widget.onMediaPicked?.call(state.selectedAssetList, null);
    context.read<HQPickerBloc>().add(const ToggleSheetEvent());
  }

  Future<void> pickMediaCamera(BuildContext context, ImageSource source) async {
    XFile? myFile;
    if (widget.widget.requestType == HQPickerRequestType.video) {
      myFile = await ImagePicker().pickVideo(
        source: source,
        preferredCameraDevice:
            widget.widget.cameraImageSettings?.preferredCameraDevice ?? CameraDevice.rear,
      );
    } else {
      myFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: widget.widget.cameraImageSettings?.imageQuality,
        preferredCameraDevice:
            widget.widget.cameraImageSettings?.preferredCameraDevice ?? CameraDevice.rear,
        maxWidth: widget.widget.cameraImageSettings?.maxWidth,
        maxHeight: widget.widget.cameraImageSettings?.maxHeight,
      );
    }

    if (myFile != null) {
      File file = File(myFile.path);
      try {
        if (widget.widget.requestType != HQPickerRequestType.video) {
          if (Platform.isAndroid) {
            await FlutterSaver.saveImageAndroid(fileImage: file);
          } else if (Platform.isIOS) {
            await FlutterSaver.saveImageIos(fileImage: file);
          }
        }
      } catch (e) {
        debugPrint('Save to gallery error: $e');
      }

      if (context.mounted) {
        context.read<HQPickerBloc>().add(
          LoadAlbumsEvent(
            requestType: widget.widget.requestType,
            fetchFileCounts: true,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                          ? widget.widget.loading ?? const CircularProgressIndicator.adaptive()
                          : Text(
                              widget.widget.textEmptyList,
                              style: widget.widget.config.theme.resolvedEmptyListTextStyle,
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
                                  controller: widget.controller,
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
                                      if (widget.widget.isRealCameraView) {
                                        return HQPickerCameraPreviewWidget(
                                          pickImageCamera: (source) =>
                                              pickMediaCamera(context, source),
                                        );
                                      } else {
                                        return HQPickerFackeCameraWidget(
                                          pickImageCamera: (source) =>
                                              pickMediaCamera(context, source),
                                        );
                                      }
                                    } else {
                                      AssetEntity assetEntity = state.assetsList[index - 1];
                                      return assetWidget(
                                        context,
                                        assetEntity,
                                        widget.widget.maxCountPickMedia,
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
                        child: IconTheme(
                          data: IconThemeData(color: theme.colorScheme.onPrimary),
                          child: widget.widget.config.icons.send,
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
                          style: widget.widget.config.theme.resolvedBadgeTextStyle,
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
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          context.read<HQPickerBloc>().add(ToggleAssetSelectionEvent(assetEntity, maxCount));
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: AssetEntityImage(
                assetEntity,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(200),
                thumbnailFormat: ThumbnailFormat.jpeg,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: IconTheme(
                      data: const IconThemeData(color: Colors.red),
                      child: widget.widget.config.icons.error,
                    ),
                  );
                },
              ),
            ),
            if (assetEntity.type == AssetType.video)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconTheme(
                        data: const IconThemeData(color: Colors.white, size: 12),
                        child: widget.widget.config.icons.play,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatDuration(assetEntity.duration),
                        style: widget.widget.config.theme.resolvedVideoDurationTextStyle,
                      ),
                    ],
                  ),
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
                  child: IconTheme(
                    data: const IconThemeData(color: Colors.white, size: 30),
                    child: widget.widget.config.icons.check,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
