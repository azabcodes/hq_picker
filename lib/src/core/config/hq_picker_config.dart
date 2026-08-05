import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'hq_picker_enums.dart';
import 'hq_picker_icons.dart';
import 'hq_picker_localizations.dart';
import 'hq_picker_theme.dart';

/// Media sorting order in picker grid.
enum HQPickerSortOrder { newestFirst, oldestFirst }

/// Signature for a custom asset item tile builder.
typedef HQAssetItemBuilder = Widget Function(
  BuildContext context,
  AssetEntity asset,
  bool isSelected,
  int? selectionIndex,
);

/// Signature for a custom snackbar/toast builder.
typedef HQPickerSnackBarBuilder = void Function(BuildContext context, String message);

/// Signature for a custom album filter predicate.
typedef HQAlbumFilter = bool Function(AssetPathEntity album);

/// Signature for a custom picker header builder.
typedef HQHeaderBuilder = Widget Function(
  BuildContext context,
  AssetPathEntity? currentAlbum,
  List<AssetPathEntity> albums,
  void Function(AssetPathEntity album) onSelectAlbum,
);

/// Signature for a custom bottom send bar builder.
typedef HQBottomSendBarBuilder = Widget Function(
  BuildContext context,
  List<AssetEntity> selectedAssets,
  List<FileSystemEntity> selectedFiles,
  VoidCallback onConfirm,
);

/// Signature for a custom permission dialog builder.
typedef HQPermissionDialogBuilder = Widget Function(
  BuildContext context,
  VoidCallback onRequestPermission,
  VoidCallback onOpenSettings,
);

class HQPickerConfig {
  final HQPickerTheme theme;
  final HQPickerLocalizations localizations;
  final HQPickerIcons icons;
  final bool compressImage;
  final int compressQuality;

  /// Optional minimum file size in bytes.
  final int? minFileSize;

  /// Optional maximum file size in bytes (e.g. 50 * 1024 * 1024 for 50MB).
  final int? maxFileSize;

  /// Optional minimum video duration.
  final Duration? minVideoDuration;

  /// Optional maximum video duration.
  final Duration? maxVideoDuration;

  /// Sort order for gallery assets (newestFirst or oldestFirst).
  final HQPickerSortOrder sortOrder;

  /// Grid customization options
  final int? gridCrossAxisCount;
  final double gridCrossAxisSpacing;
  final double gridMainAxisSpacing;
  final double gridChildAspectRatio;
  final BorderRadius? gridItemBorderRadius;

  /// Selection badge & animation options
  final HQPickerSelectionStyle selectionStyle;
  final HQPickerBadgePosition badgePosition;
  final bool enableSelectionAnimation;

  /// Fullscreen preview & video behavior options
  final bool enableFullScreenPreview;
  final bool autoPlayVideoPreview;
  final bool muteVideoPreview;

  /// Camera customization options
  final HQPickerCameraLens preferredCameraLens;
  final HQPickerCameraCaptureMode cameraCaptureMode;
  final Widget Function(BuildContext context)? cameraOverlayBuilder;

  /// File & Document View options
  final HQPickerFileViewMode fileViewMode;
  final bool enableDocumentPreview;
  final Map<String, Widget>? customFileTypeIcons;

  /// Gestures & Drag-to-select options
  final bool enableDragSelect;
  final HQPickerGestureAction doubleTapAction;
  final HQPickerGestureAction longPressAction;

  /// Custom send bar & animation options
  final HQBottomSendBarBuilder? bottomSendBarBuilder;
  final bool sendButtonAnimation;

  /// Custom permission dialog builder
  final HQPermissionDialogBuilder? permissionDialogBuilder;

  /// Album filter & header builder
  final HQAlbumFilter? albumFilter;
  final HQHeaderBuilder? headerBuilder;

  /// Callbacks
  final VoidCallback? onMaxCountReached;
  final void Function(AssetEntity asset)? onAssetTap;
  final void Function(AssetPathEntity album)? onAlbumChanged;

  /// Optional custom grid item tile builder.
  final HQAssetItemBuilder? assetItemBuilder;

  /// Whether to show the built-in snack-bar when selection errors occur.
  final bool showSnackBar;

  /// Optional custom callback invoked instead of the built-in [SnackBar].
  final HQPickerSnackBarBuilder? onSnackBar;

  /// Widget shown as an overlay while assets are being processed.
  final Widget? loadingWidget;

  /// Optional custom widget displayed when an album or tab has no items.
  final Widget? emptyWidget;

  /// Optional custom scroll physics for asset grids.
  final ScrollPhysics? scrollPhysics;

  const HQPickerConfig({
    this.theme = const HQPickerTheme(),
    this.localizations = const HQPickerLocalizations(),
    this.icons = const HQPickerIcons(),
    this.compressImage = true,
    this.compressQuality = 80,
    this.minFileSize,
    this.maxFileSize,
    this.minVideoDuration,
    this.maxVideoDuration,
    this.sortOrder = HQPickerSortOrder.newestFirst,
    this.gridCrossAxisCount,
    this.gridCrossAxisSpacing = 2.0,
    this.gridMainAxisSpacing = 2.0,
    this.gridChildAspectRatio = 1.0,
    this.gridItemBorderRadius,
    this.selectionStyle = HQPickerSelectionStyle.number,
    this.badgePosition = HQPickerBadgePosition.topRight,
    this.enableSelectionAnimation = true,
    this.enableFullScreenPreview = true,
    this.autoPlayVideoPreview = false,
    this.muteVideoPreview = true,
    this.preferredCameraLens = HQPickerCameraLens.back,
    this.cameraCaptureMode = HQPickerCameraCaptureMode.all,
    this.cameraOverlayBuilder,
    this.fileViewMode = HQPickerFileViewMode.list,
    this.enableDocumentPreview = true,
    this.customFileTypeIcons,
    this.enableDragSelect = false,
    this.doubleTapAction = HQPickerGestureAction.none,
    this.longPressAction = HQPickerGestureAction.preview,
    this.bottomSendBarBuilder,
    this.sendButtonAnimation = true,
    this.permissionDialogBuilder,
    this.albumFilter,
    this.headerBuilder,
    this.onMaxCountReached,
    this.onAssetTap,
    this.onAlbumChanged,
    this.assetItemBuilder,
    this.showSnackBar = true,
    this.onSnackBar,
    this.loadingWidget,
    this.emptyWidget,
    this.scrollPhysics,
  });

  /// Shows the notification (snack-bar or custom toast) to the user.
  /// Respects [showSnackBar] and [onSnackBar] settings.
  void showSelectionError(BuildContext context, String message) {
    if (onSnackBar != null) {
      onSnackBar!(context, message);
      return;
    }
    if (!showSnackBar) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: theme.backgroundColor,
        margin: const EdgeInsets.all(15.0),
        behavior: SnackBarBehavior.floating,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        content: Text(message, style: theme.resolvedSnackBarTextStyle),
      ),
    );
  }
}


