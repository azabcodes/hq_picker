import 'package:flutter/material.dart';

import 'hq_picker_icons.dart';
import 'hq_picker_localizations.dart';
import 'hq_picker_theme.dart';

import 'package:photo_manager/photo_manager.dart';

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
///
/// [context] is the current [BuildContext].
/// [message] is the message to display (e.g. "No image selected").
typedef HQPickerSnackBarBuilder = void Function(BuildContext context, String message);

class HQPickerConfig {
  final HQPickerTheme theme;
  final HQPickerLocalizations localizations;
  final HQPickerIcons icons;
  final bool compressImage;
  final int compressQuality;

  /// Optional maximum file size in bytes (e.g. 50 * 1024 * 1024 for 50MB).
  /// Items exceeding this size will trigger a warning.
  final int? maxFileSize;

  /// Sort order for gallery assets (newestFirst or oldestFirst).
  final HQPickerSortOrder sortOrder;

  /// Optional custom grid item tile builder.
  final HQAssetItemBuilder? assetItemBuilder;

  /// Whether to show the built-in snack-bar when the user tries to confirm
  /// without selecting any media. Defaults to `true`.
  ///
  /// Set to `false` to silence it completely, or provide [onSnackBar] to
  /// replace it with your own toast/dialog.
  final bool showSnackBar;

  /// Optional custom callback invoked instead of the built-in [SnackBar].
  final HQPickerSnackBarBuilder? onSnackBar;

  /// Widget shown as an overlay while assets are being processed
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
    this.maxFileSize,
    this.sortOrder = HQPickerSortOrder.newestFirst,
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
