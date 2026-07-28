// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../core/bloc/hq_picker_bloc.dart';
import '../core/bloc/hq_picker_event.dart';
import '../core/bloc/hq_picker_state.dart';
import '../core/config/hq_picker_config.dart';

/// A standalone widget for a single grid asset item in the Instagram-style picker.
///
/// Renders the thumbnail, video-duration badge, selection overlay,
/// and multi-selection badge for a single [AssetEntity].
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

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HQPickerBloc>();
    final isSelected = state.selectedAssetList.contains(assetEntity);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          bloc.add(SelectEntityEvent(assetEntity));
          if (state.isMultiple) {
            // In multi-select mode, tap toggles the asset in selectedAssetList
            bloc.add(ToggleAssetSelectionEvent(assetEntity, maxCount));
          } else {
            // In single-select mode, just set the single selected asset
            bloc.add(SetSelectedAssetsEvent([assetEntity]));
          }
        },
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

            // ── Single-select overlay tint ──────────────────────────────────
            Positioned.fill(
              child: Container(
                color: assetEntity == state.selectedEntity ? Colors.white60 : Colors.transparent,
              ),
            ),

            // ── Multi-select badge ───────────────────────────────────────────
            if (state.isMultiple)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    bloc.add(ToggleAssetSelectionEvent(assetEntity, maxCount));
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? config.theme.badgeBackgroundColor : Colors.white12,
                          shape: BoxShape.circle,
                          border: Border.all(width: 1.5, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            isSelected ? '${state.selectedAssetList.indexOf(assetEntity) + 1}' : '',
                            style: config.theme.resolvedBadgeTextStyle.copyWith(
                              color: isSelected ? null : Colors.transparent,
                            ),
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
    );
  }

  static String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
