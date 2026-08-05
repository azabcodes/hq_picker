import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../core/bloc/hq_picker_bloc.dart';
import '../core/bloc/hq_picker_event.dart';
import '../core/bloc/hq_picker_state.dart';
import '../core/config/hq_picker_config.dart';
import '../core/config/hq_picker_enums.dart';

/// A standalone widget for a single grid asset item in the Instagram-style picker.
class HQAssetItem extends StatelessWidget {
  final AssetEntity assetEntity;
  final HQPickerState state;
  final int maxCount;
  final HQPickerConfig config;

  const HQAssetItem({
    super.key,
    required this.assetEntity,
    required this.state,
    required this.maxCount,
    required this.config,
  });

  Alignment _resolveBadgeAlignment() {
    switch (config.badgePosition) {
      case HQPickerBadgePosition.topRight:
        return Alignment.topRight;
      case HQPickerBadgePosition.topLeft:
        return Alignment.topLeft;
      case HQPickerBadgePosition.bottomRight:
        return Alignment.bottomRight;
      case HQPickerBadgePosition.bottomLeft:
        return Alignment.bottomLeft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HQPickerBloc>();
    final isSelected = state.selectedAssetIdsSet.contains(assetEntity.id);
    final selectionIndex = isSelected ? state.selectedAssetList.indexOf(assetEntity) + 1 : null;

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

      bloc.add(ToggleAssetSelectionEvent(assetEntity, maxCount));
    }

    void executeAction(HQPickerGestureAction action) {
      switch (action) {
        case HQPickerGestureAction.none:
          break;
        case HQPickerGestureAction.select:
          handleTap();
          break;
        case HQPickerGestureAction.preview:
          _showFullScreenPreview(context, assetEntity);
          break;
        case HQPickerGestureAction.showInfo:
          _showAssetInfoDialog(context, assetEntity);
          break;
      }
    }

    if (config.assetItemBuilder != null) {
      return GestureDetector(
        onTap: handleTap,
        onDoubleTap: () => executeAction(config.doubleTapAction),
        onLongPress: () => executeAction(config.longPressAction),
        child: config.assetItemBuilder!(context, assetEntity, isSelected, selectionIndex),
      );
    }

    final borderRadius = config.gridItemBorderRadius ?? BorderRadius.zero;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: handleTap,
        onDoubleTap: () => executeAction(config.doubleTapAction),
        onLongPress: () => executeAction(config.longPressAction),
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
                // ── Thumbnail ────────────────────────────────────────────────────
                Positioned.fill(
                  child: AssetEntityImage(
                    assetEntity,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(250),
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

                // ── Video duration badge ─────────────────────────────────────────
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

                // ── GIF badge ────────────────────────────────────────────────────
                if (assetEntity.title?.toLowerCase().endsWith('.gif') == true ||
                    assetEntity.mimeType?.contains('gif') == true)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: config.icons.gifBadge ??
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

                // ── Single-select overlay tint ──────────────────────────────────
                if (assetEntity == state.selectedEntity)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white60,
                    ),
                  ),

                // ── Multi-select badge ───────────────────────────────────────────
                if (state.isMultiple && config.selectionStyle != HQPickerSelectionStyle.borderOnly)
                  Positioned.fill(
                    child: Align(
                      alignment: _resolveBadgeAlignment(),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: AnimatedScale(
                          scale: config.enableSelectionAnimation ? (isSelected ? 1.05 : 0.9) : 1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? config.theme.badgeBackgroundColor : Colors.white12,
                              shape: BoxShape.circle,
                              border: Border.all(width: 1.5, color: Colors.white),
                            ),
                            padding: const EdgeInsets.all(6.0),
                            child: config.selectionStyle == HQPickerSelectionStyle.checkMark
                                ? (isSelected
                                    ? Icon(Icons.check, size: 14, color: config.theme.badgeTextColor)
                                    : const SizedBox(width: 14, height: 14))
                                : Text(
                                    isSelected ? '$selectionIndex' : '',
                                    style: config.theme.resolvedBadgeTextStyle.copyWith(
                                      color: isSelected ? null : Colors.transparent,
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

  static String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _showFullScreenPreview(BuildContext context, AssetEntity asset) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: AssetEntityImage(
                    asset,
                    isOriginal: true,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAssetInfoDialog(BuildContext context, AssetEntity asset) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: config.theme.backgroundColor,
          title: Text('Asset Details', style: config.theme.resolvedDialogTitleTextStyle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${asset.id}', style: config.theme.resolvedDialogContentTextStyle),
              const SizedBox(height: 6),
              Text('Type: ${asset.type.name.toUpperCase()}', style: config.theme.resolvedDialogContentTextStyle),
              const SizedBox(height: 6),
              Text('Resolution: ${asset.width} x ${asset.height}', style: config.theme.resolvedDialogContentTextStyle),
              if (asset.type == AssetType.video) ...[
                const SizedBox(height: 6),
                Text('Duration: ${_formatDuration(asset.duration)}', style: config.theme.resolvedDialogContentTextStyle),
              ],
              const SizedBox(height: 6),
              Text('Created: ${asset.createDateTime}', style: config.theme.resolvedDialogContentTextStyle),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close', style: config.theme.resolvedDialogConfirmTextStyle),
            ),
          ],
        );
      },
    );
  }
}



