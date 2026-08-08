import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:hq_picker/src/core/bloc/hq_picker_state.dart';
import 'package:hq_picker/src/telegram/telegram_media_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../bloc/hq_picker_bloc.dart';
import '../bloc/hq_picker_event.dart';
import '../config/hq_picker_config.dart';
import '../config/hq_picker_enums.dart';
import '../tools/hq_picker_asset_visuals.dart';
import '../tools/media_services.dart';
import 'camera_preview_widget.dart';
import 'hq_media_preview_dialog.dart';

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
  HQPickerConfig get config => widget.widget.config;

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
                                  physics:
                                      widget.widget.config.scrollPhysics ??
                                      const BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                  scrollCacheExtent: const ScrollCacheExtent.pixels(1500.0),
                                  addRepaintBoundaries: true,
                                  addAutomaticKeepAlives: true,
                                  itemCount: state.assetsList.length + 1,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: widget.widget.config.gridCrossAxisCount ?? 3,
                                    crossAxisSpacing: widget.widget.config.gridCrossAxisSpacing,
                                    mainAxisSpacing: widget.widget.config.gridMainAxisSpacing,
                                    childAspectRatio: widget.widget.config.gridChildAspectRatio,
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
                                      return KeyedSubtree(
                                        key: ValueKey(assetEntity.id),
                                        child: assetWidget(
                                          context,
                                          assetEntity,
                                          widget.widget.maxCountPickMedia,
                                          state,
                                        ),
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
            if (widget.widget.config.bottomSendBarBuilder != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: widget.widget.config.bottomSendBarBuilder!(
                  context,
                  state.selectedAssetList,
                  state.selectedFiles,
                  () => _sendSelectedFiles(context, state),
                ),
              )
            else if (state.selectedAssetList.isNotEmpty || state.selectedFiles.isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.10,
                right: 30,
                child: AnimatedScale(
                  scale: 1.0,
                  // Previously both branches of this condition were `1.0`,
                  // so `sendButtonAnimation` had no observable effect at all.
                  // Since this widget is only mounted while there's a
                  // selection (conditionally built above), there's no prior
                  // frame to scale-animate *from* — so what the flag can
                  // meaningfully control is whether the built-in Flutter
                  // insert transition gets any duration to run in.
                  duration: widget.widget.config.sendButtonAnimation
                      ? const Duration(milliseconds: 200)
                      : Duration.zero,
                  curve: Curves.easeOutCubic,
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
                            '${state.selectedAssetList.length + state.selectedFiles.length}',
                            style: widget.widget.config.theme.resolvedBadgeTextStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
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
    int? selectionIndex = isSelected
        ? (state.selectedAssetIndexById[assetEntity.id] ?? -1) + 1
        : null;
    final config = widget.widget.config;

    void handleTap() {
      HapticFeedback.selectionClick();
      if (config.onAssetTap != null) {
        config.onAssetTap!(assetEntity);
      }

      if (!isSelected && maxCount > 1 && state.selectedAssetList.length >= maxCount) {
        config.onMaxCountReached?.call();
        config.showSelectionError(
          context,
          '${config.localizations.maxSelectTitle} $maxCount',
        );
        return;
      }

      if (assetEntity.type == AssetType.video) {
        if (config.minVideoDuration != null &&
            assetEntity.duration < config.minVideoDuration!.inSeconds) {
          config.showSelectionError(
            context,
            'Video duration is shorter than minimum allowed (${config.minVideoDuration!.inSeconds}s)',
          );
          return;
        }
        if (config.maxVideoDuration != null &&
            assetEntity.duration > config.maxVideoDuration!.inSeconds) {
          config.showSelectionError(
            context,
            'Video duration exceeds maximum allowed (${config.maxVideoDuration!.inSeconds}s)',
          );
          return;
        }
      }

      context.read<HQPickerBloc>().add(ToggleAssetSelectionEvent(assetEntity, maxCount));
    }

    if (config.assetItemBuilder != null) {
      return GestureDetector(
        onTap: handleTap,
        onLongPress: () {
          if (config.enableFullScreenPreview) {
            _showFullScreenPreview(context, assetEntity);
          }
        },
        child: config.assetItemBuilder!(
          context,
          assetEntity,
          isSelected,
          selectionIndex,
        ),
      );
    }

    final borderRadius = config.gridItemBorderRadius ?? BorderRadius.zero;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: handleTap,
        onLongPress: () {
          if (config.enableFullScreenPreview) {
            _showFullScreenPreview(context, assetEntity);
          }
        },
        child: ClipRRect(
          borderRadius: borderRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: isSelected && config.selectionStyle == HQPickerSelectionStyle.borderOnly
                  ? Border.all(color: config.theme.badgeBackgroundColor, width: 3)
                  : null,
            ),
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
                          child: config.icons.error,
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
                            child: config.icons.play,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _formatDuration(assetEntity.duration),
                            style: config.theme.resolvedVideoDurationTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (HQPickerAssetVisuals.isGif(assetEntity))
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child:
                        config.icons.gifBadge ??
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
                if (config.selectionStyle != HQPickerSelectionStyle.borderOnly)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: isSelected ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          alignment: HQPickerAssetVisuals.resolveBadgeAlignment(
                            config.badgePosition,
                          ),
                          padding: const EdgeInsets.all(5.0),
                          color: isSelected ? Colors.black38 : Colors.transparent,
                          child: AnimatedScale(
                            // The badge container is now always mounted (only
                            // its opacity toggles), so — unlike before — this
                            // actually has a previous frame to animate from.
                            scale: config.enableSelectionAnimation
                                ? (isSelected ? 1.0 : 0.85)
                                : 1.0,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOutCubic,
                            child: Container(
                              decoration: BoxDecoration(
                                color: config.theme.badgeBackgroundColor,
                                shape: BoxShape.circle,
                                border: Border.all(width: 1.5, color: Colors.white),
                              ),
                              padding: const EdgeInsets.all(6.0),
                              child: config.selectionStyle == HQPickerSelectionStyle.checkMark
                                  ? Icon(Icons.check, size: 14, color: config.theme.badgeTextColor)
                                  : Text(
                                      isSelected ? '$selectionIndex' : '',
                                      style: config.theme.resolvedBadgeTextStyle,
                                    ),
                            ),
                          ),
                        ),
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

  void _showFullScreenPreview(BuildContext context, AssetEntity asset) {
    HQMediaPreviewDialog.show(context, asset, config);
  }

  String _formatDuration(int seconds) => HQPickerAssetVisuals.formatDuration(seconds);
}
