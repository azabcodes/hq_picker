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
typedef HQAssetItemBuilder =
    Widget Function(
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
typedef HQHeaderBuilder =
    Widget Function(
      BuildContext context,
      AssetPathEntity? currentAlbum,
      List<AssetPathEntity> albums,
      void Function(AssetPathEntity album) onSelectAlbum,
    );

/// Signature for a custom bottom send bar builder.
typedef HQBottomSendBarBuilder =
    Widget Function(
      BuildContext context,
      List<AssetEntity> selectedAssets,
      List<FileSystemEntity> selectedFiles,
      VoidCallback onConfirm,
    );

/// Signature for a custom permission dialog builder.
typedef HQPermissionDialogBuilder =
    Widget Function(
      BuildContext context,
      VoidCallback onRequestPermission,
      VoidCallback onOpenSettings,
    );

/// Signature for a custom asset preview dialog builder.
typedef HQAssetPreviewBuilder =
    Widget Function(
      BuildContext context,
      AssetEntity asset,
    );

/// Signature for a custom confirm button builder.
typedef HQConfirmButtonBuilder =
    Widget Function(
      BuildContext context,
      List<AssetEntity> selectedAssets,
      VoidCallback onConfirm,
    );

/// Signature for a custom AppBar builder (e.g. for Instagram shape).
typedef HQAppBarBuilder =
    PreferredSizeWidget Function(
      BuildContext context,
      AssetPathEntity? currentAlbum,
      List<AssetEntity> selectedAssets,
      VoidCallback onConfirm,
      VoidCallback onBack,
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

  /// Custom asset preview dialog builder
  final HQAssetPreviewBuilder? previewDialogBuilder;

  /// Custom confirm button builder
  final HQConfirmButtonBuilder? confirmButtonBuilder;

  /// Custom AppBar builder (for Instagram shape)
  final HQAppBarBuilder? appBarBuilder;

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

  /// BoxFit applied to top preview image in Instagram picker shape.
  final BoxFit previewFit;

  /// BoxFit applied to thumbnails in asset grid tiles.
  final BoxFit gridItemFit;

  /// Size of square thumbnail generated for grid items.
  final int thumbnailSize;

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
    this.previewDialogBuilder,
    this.confirmButtonBuilder,
    this.appBarBuilder,
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
    this.scrollPhysics = const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
    this.previewFit = BoxFit.cover,
    this.gridItemFit = BoxFit.cover,
    this.thumbnailSize = 200,
  });

  HQPickerConfig copyWith({
    HQPickerTheme? theme,
    HQPickerLocalizations? localizations,
    HQPickerIcons? icons,
    bool? compressImage,
    int? compressQuality,
    int? minFileSize,
    int? maxFileSize,
    Duration? minVideoDuration,
    Duration? maxVideoDuration,
    HQPickerSortOrder? sortOrder,
    int? gridCrossAxisCount,
    double? gridCrossAxisSpacing,
    double? gridMainAxisSpacing,
    double? gridChildAspectRatio,
    BorderRadius? gridItemBorderRadius,
    HQPickerSelectionStyle? selectionStyle,
    HQPickerBadgePosition? badgePosition,
    bool? enableSelectionAnimation,
    bool? enableFullScreenPreview,
    bool? autoPlayVideoPreview,
    bool? muteVideoPreview,
    HQPickerCameraLens? preferredCameraLens,
    HQPickerCameraCaptureMode? cameraCaptureMode,
    Widget Function(BuildContext context)? cameraOverlayBuilder,
    HQPickerFileViewMode? fileViewMode,
    bool? enableDocumentPreview,
    Map<String, Widget>? customFileTypeIcons,
    bool? enableDragSelect,
    HQPickerGestureAction? doubleTapAction,
    HQPickerGestureAction? longPressAction,
    HQBottomSendBarBuilder? bottomSendBarBuilder,
    bool? sendButtonAnimation,
    HQPermissionDialogBuilder? permissionDialogBuilder,
    HQAssetPreviewBuilder? previewDialogBuilder,
    HQConfirmButtonBuilder? confirmButtonBuilder,
    HQAppBarBuilder? appBarBuilder,
    HQAlbumFilter? albumFilter,
    HQHeaderBuilder? headerBuilder,
    VoidCallback? onMaxCountReached,
    void Function(AssetEntity asset)? onAssetTap,
    void Function(AssetPathEntity album)? onAlbumChanged,
    HQAssetItemBuilder? assetItemBuilder,
    bool? showSnackBar,
    HQPickerSnackBarBuilder? onSnackBar,
    Widget? loadingWidget,
    Widget? emptyWidget,
    ScrollPhysics? scrollPhysics,
    BoxFit? previewFit,
    BoxFit? gridItemFit,
    int? thumbnailSize,
  }) {
    return HQPickerConfig(
      theme: theme ?? this.theme,
      localizations: localizations ?? this.localizations,
      icons: icons ?? this.icons,
      compressImage: compressImage ?? this.compressImage,
      compressQuality: compressQuality ?? this.compressQuality,
      minFileSize: minFileSize ?? this.minFileSize,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      minVideoDuration: minVideoDuration ?? this.minVideoDuration,
      maxVideoDuration: maxVideoDuration ?? this.maxVideoDuration,
      sortOrder: sortOrder ?? this.sortOrder,
      gridCrossAxisCount: gridCrossAxisCount ?? this.gridCrossAxisCount,
      gridCrossAxisSpacing: gridCrossAxisSpacing ?? this.gridCrossAxisSpacing,
      gridMainAxisSpacing: gridMainAxisSpacing ?? this.gridMainAxisSpacing,
      gridChildAspectRatio: gridChildAspectRatio ?? this.gridChildAspectRatio,
      gridItemBorderRadius: gridItemBorderRadius ?? this.gridItemBorderRadius,
      selectionStyle: selectionStyle ?? this.selectionStyle,
      badgePosition: badgePosition ?? this.badgePosition,
      enableSelectionAnimation: enableSelectionAnimation ?? this.enableSelectionAnimation,
      enableFullScreenPreview: enableFullScreenPreview ?? this.enableFullScreenPreview,
      autoPlayVideoPreview: autoPlayVideoPreview ?? this.autoPlayVideoPreview,
      muteVideoPreview: muteVideoPreview ?? this.muteVideoPreview,
      preferredCameraLens: preferredCameraLens ?? this.preferredCameraLens,
      cameraCaptureMode: cameraCaptureMode ?? this.cameraCaptureMode,
      cameraOverlayBuilder: cameraOverlayBuilder ?? this.cameraOverlayBuilder,
      fileViewMode: fileViewMode ?? this.fileViewMode,
      enableDocumentPreview: enableDocumentPreview ?? this.enableDocumentPreview,
      customFileTypeIcons: customFileTypeIcons ?? this.customFileTypeIcons,
      enableDragSelect: enableDragSelect ?? this.enableDragSelect,
      doubleTapAction: doubleTapAction ?? this.doubleTapAction,
      longPressAction: longPressAction ?? this.longPressAction,
      bottomSendBarBuilder: bottomSendBarBuilder ?? this.bottomSendBarBuilder,
      sendButtonAnimation: sendButtonAnimation ?? this.sendButtonAnimation,
      permissionDialogBuilder: permissionDialogBuilder ?? this.permissionDialogBuilder,
      previewDialogBuilder: previewDialogBuilder ?? this.previewDialogBuilder,
      confirmButtonBuilder: confirmButtonBuilder ?? this.confirmButtonBuilder,
      appBarBuilder: appBarBuilder ?? this.appBarBuilder,
      albumFilter: albumFilter ?? this.albumFilter,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      onMaxCountReached: onMaxCountReached ?? this.onMaxCountReached,
      onAssetTap: onAssetTap ?? this.onAssetTap,
      onAlbumChanged: onAlbumChanged ?? this.onAlbumChanged,
      assetItemBuilder: assetItemBuilder ?? this.assetItemBuilder,
      showSnackBar: showSnackBar ?? this.showSnackBar,
      onSnackBar: onSnackBar ?? this.onSnackBar,
      loadingWidget: loadingWidget ?? this.loadingWidget,
      emptyWidget: emptyWidget ?? this.emptyWidget,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      previewFit: previewFit ?? this.previewFit,
      gridItemFit: gridItemFit ?? this.gridItemFit,
      thumbnailSize: thumbnailSize ?? this.thumbnailSize,
    );
  }

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
