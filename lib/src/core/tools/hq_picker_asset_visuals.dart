import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../config/hq_picker_enums.dart';

/// Shared visual helpers for grid asset tiles.
///
/// [HQAssetItem] (Instagram picker) and the Telegram picker's default
/// `assetWidget` used to each carry their own copy of badge-alignment,
/// GIF-detection, and duration-formatting logic. Centralizing them here
/// means a future tweak (e.g. a new badge position, a different GIF
/// detection heuristic) only needs to be made once, and both pickers stay
/// visually consistent by construction.
class HQPickerAssetVisuals {
  const HQPickerAssetVisuals._();

  static Alignment resolveBadgeAlignment(HQPickerBadgePosition position) {
    switch (position) {
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

  static bool isGif(AssetEntity asset) {
    return asset.title?.toLowerCase().endsWith('.gif') == true ||
        asset.mimeType?.contains('gif') == true;
  }

  static String formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
