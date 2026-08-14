import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../core/bloc/hq_picker_bloc.dart';
import '../core/bloc/hq_picker_event.dart';
import '../core/bloc/hq_picker_state.dart';
import '../core/components/hq_media_preview_dialog.dart';
import '../core/config/hq_picker_config.dart';
import '../core/config/hq_picker_enums.dart';
import '../core/tools/hq_picker_asset_visuals.dart';

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

  Alignment _resolveBadgeAlignment() =>
      HQPickerAssetVisuals.resolveBadgeAlignment(config.badgePosition);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HQPickerBloc, HQPickerState, _HQAssetItemSelectionState>(
      selector: (state) {
        final isSelected = state.selectedAssetIdsSet.contains(assetEntity.id);
        final selectionIndex = isSelected
            ? (state.selectedAssetIndexById[assetEntity.id] ?? -1) + 1
            : null;
        return _HQAssetItemSelectionState(
          isSelected: isSelected,
          selectionIndex: selectionIndex,
          selectedCount: state.selectedAssetList.length,
        );
      },
      builder: (context, selectionState) {
        final isSelected = selectionState.isSelected;
        final selectionIndex = selectionState.selectionIndex;
        final selectedCount = selectionState.selectedCount;
        final bloc = context.read<HQPickerBloc>();

        void handleTap() {
          HapticFeedback.selectionClick();
          if (config.onAssetTap != null) {
            config.onAssetTap!(assetEntity);
          }

          if (!isSelected && maxCount > 1 && selectedCount >= maxCount) {
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
          child: Container(
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
                    thumbnailSize: ThumbnailSize.square(config.thumbnailSize),
                    thumbnailFormat: ThumbnailFormat.jpeg,
                    fit: config.gridItemFit,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const ColoredBox(color: Colors.white10);
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
                              color: isSelected
                                  ? config.theme.badgeBackgroundColor
                                  : Colors.white12,
                              shape: BoxShape.circle,
                              border: Border.all(width: 1.5, color: Colors.white),
                            ),
                            padding: const EdgeInsets.all(6.0),
                            child: config.selectionStyle == HQPickerSelectionStyle.checkMark
                                ? (isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 14,
                                          color: config.theme.badgeTextColor,
                                        )
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
  },
);
  }

  static String _formatDuration(int seconds) => HQPickerAssetVisuals.formatDuration(seconds);

  void _showFullScreenPreview(BuildContext context, AssetEntity asset) {
    HQMediaPreviewDialog.show(context, asset, config);
  }

  void _showAssetInfoDialog(BuildContext context, AssetEntity asset) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(config.localizations.assetDetails, style: config.theme.resolvedDialogTitleTextStyle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('ID: ${asset.id}', style: config.theme.resolvedDialogContentTextStyle),
              const SizedBox(height: 6),
              Text(
                'Type: ${asset.type.name.toUpperCase()}',
                style: config.theme.resolvedDialogContentTextStyle,
              ),
              const SizedBox(height: 6),
              Text(
                'Resolution: ${asset.width} x ${asset.height}',
                style: config.theme.resolvedDialogContentTextStyle,
              ),
              if (asset.type == AssetType.video) ...[
                const SizedBox(height: 6),
                Text(
                  'Duration: ${_formatDuration(asset.duration)}',
                  style: config.theme.resolvedDialogContentTextStyle,
                ),
              ],
              const SizedBox(height: 6),
              Text(
                'Created: ${asset.createDateTime}',
                style: config.theme.resolvedDialogContentTextStyle,
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: Text(config.localizations.close, style: config.theme.resolvedDialogConfirmTextStyle),
            ),
          ],
        );
      },
    );
  }
}

class _HQAssetItemSelectionState {
  final bool isSelected;
  final int? selectionIndex;
  final int selectedCount;

  const _HQAssetItemSelectionState({
    required this.isSelected,
    this.selectionIndex,
    required this.selectedCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _HQAssetItemSelectionState &&
          runtimeType == other.runtimeType &&
          isSelected == other.isSelected &&
          selectionIndex == other.selectionIndex &&
          selectedCount == other.selectedCount;

  @override
  int get hashCode =>
      isSelected.hashCode ^ selectionIndex.hashCode ^ selectedCount.hashCode;
}
