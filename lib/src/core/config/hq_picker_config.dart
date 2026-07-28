import 'package:flutter/material.dart';

import 'hq_picker_icons.dart';
import 'hq_picker_localizations.dart';
import 'hq_picker_theme.dart';

/// Signature for a custom snackbar/toast builder.
///
/// [context] is the current [BuildContext].
/// [message] is the message to display (e.g. "No image selected").
typedef HQPickerSnackBarBuilder = void Function(BuildContext context, String message);

class HQPickerConfig {
  final HQPickerTheme theme;
  final HQPickerLocalizations localizations;
  final HQPickerIcons icons;
  final bool enableCropping;
  final bool compressImage;
  final int compressQuality;

  /// The label shown for the "Recent" album in both pickers.
  /// Defaults to [HQPickerLocalizations.gallery] (i.e. 'Gallery').
  /// Pass a custom value here to override it, or set it via [localizations].
  // (resolved at call-site via localizations.gallery so no extra field needed)

  /// Whether to show the built-in snack-bar when the user tries to confirm
  /// without selecting any media. Defaults to `true`.
  ///
  /// Set to `false` to silence it completely, or provide [onSnackBar] to
  /// replace it with your own toast/dialog.
  final bool showSnackBar;

  /// Optional custom callback invoked instead of the built-in [SnackBar].
  ///
  /// When provided, [showSnackBar] is ignored and this callback is called
  /// whenever a "no selection" notification would be shown.
  ///
  /// Example:
  /// ```dart
  /// onSnackBar: (context, message) {
  ///   Fluttertoast.showToast(msg: message);
  /// }
  /// ```
  final HQPickerSnackBarBuilder? onSnackBar;

  /// Widget shown as an overlay while assets are being processed
  /// (cropping / compression). Defaults to a centered
  /// [CircularProgressIndicator].
  ///
  /// Example:
  /// ```dart
  /// loadingWidget: Center(
  ///   child: MyCustomSpinner(),
  /// ),
  /// ```
  final Widget? loadingWidget;

  const HQPickerConfig({
    this.theme = const HQPickerTheme(),
    this.localizations = const HQPickerLocalizations(),
    this.icons = const HQPickerIcons(),
    this.enableCropping = false,
    this.compressImage = true,
    this.compressQuality = 80,
    this.showSnackBar = true,
    this.onSnackBar,
    this.loadingWidget,
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
