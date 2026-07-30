import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
      buildWhen: (previous, current) {
        return previous.assetsList != current.assetsList ||
            previous.status != current.status ||
            previous.selectedAlbum != current.selectedAlbum ||
            (previous.scrollSize > 0.9) != (current.scrollSize > 0.9) ||
            previous.selectedAssetList.length != current.selectedAssetList.length;
      },
      builder: (context, state) {
        final showAppBar = state.scrollSize > 0.9;
        final appBarHeight = MediaQuery.of(context).size.height * 0.075;
        final topPadding = showAppBar ? appBarHeight + 10.0 : 10.0;

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
                  ? (widget.widget.config.emptyWidget ??
                      Center(
                        child: state.status == HQPickerStatus.loading
                            ? widget.widget.loading ?? const CircularProgressIndicator.adaptive()
                            : Text(
                                widget.widget.textEmptyList,
                                style: widget.widget.config.theme.resolvedEmptyListTextStyle,
                              ),
                      ))
                  : AnimatedPadding(
                      duration: const Duration(milliseconds: 250),
                      padding: EdgeInsets.only(top: topPadding, right: 10, left: 10),
                      child: Column(
                        children: [
                          if (!showAppBar) ...[
                            Container(
                              height: 5,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                context
                                    .findAncestorStateOfType<HQPickerTelegramMediaPickersState>()
                                    ?.showAlbumSelector(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      (state.selectedAlbum != null &&
                                              state.selectedAlbum!.name == 'Recent')
                                          ? widget.widget.config.localizations.gallery
                                          : (state.selectedAlbum?.name ??
                                                widget.widget.config.localizations.gallery),
                                      style: widget.widget.config.theme.resolvedAlbumNameTextStyle,
                                    ),
                                    const SizedBox(width: 4),
                                    IconTheme(
                                      data: IconThemeData(
                                        color: theme.colorScheme.onPrimary,
                                        size: 24,
                                      ),
                                      child: widget.widget.config.icons.dropdown,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: GridView.builder(
                                  controller: widget.controller,
                                  physics: widget.widget.config.scrollPhysics ??
                                      const BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                  scrollCacheExtent: const ScrollCacheExtent.pixels(1500.0),
                                  addRepaintBoundaries: true,
                                  addAutomaticKeepAlives: true,
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
    bool isSelected = state.selectedAssetIdsSet.contains(assetEntity.id);
    int? selectionIndex = isSelected ? state.selectedAssetList.indexOf(assetEntity) + 1 : null;

    if (widget.widget.config.assetItemBuilder != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          context.read<HQPickerBloc>().add(ToggleAssetSelectionEvent(assetEntity, maxCount));
        },
        child: widget.widget.config.assetItemBuilder!(
          context,
          assetEntity,
          isSelected,
          selectionIndex,
        ),
      );
    }

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
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
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.white10,
                  );
                },
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
            if (assetEntity.title?.toLowerCase().endsWith('.gif') == true ||
                assetEntity.mimeType?.contains('gif') == true)
              Positioned(
                bottom: 4,
                left: 4,
                child: widget.widget.config.icons.gifBadge ??
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'GIF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              ),
            if (isSelected)
              Positioned.fill(
                child: AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
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
