import 'package:flutter/material.dart';

/// Configurable colors and text styles across HQPicker.
class HQPickerTheme {
  final Color backgroundColor;
  final Color appbarColor;
  final Color bottomBarColor;
  final Color primaryColor;
  final Color confirmButtonColor;
  final Color confirmTextColor;
  final Color textColor;
  final Color iconCameraColor;
  final Color iconGalleryColor;
  final Color indicatorColor;
  final Color emptyListTextColor;
  final Color backgroundDropDownColor;
  final Color textSelectedListAssetColor;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;
  final Color selectedItemOverlayColor;

  // ── Text Styles ─────────────────────────────────────────────────────────────

  /// Style for the confirm button label (e.g. "Send").
  final TextStyle? confirmButtonTextStyle;

  /// Style for the album name shown in the header / appbar.
  final TextStyle? albumNameTextStyle;

  /// Style for the file-count text shown next to each album in the dropdown.
  final TextStyle? albumCountTextStyle;

  /// Style for the empty-state message (e.g. "No albums found").
  final TextStyle? emptyListTextStyle;

  /// Style for the counter badge on the send FAB (e.g. "3").
  final TextStyle? badgeTextStyle;

  /// Style for the video-duration overlay text (e.g. "01:23").
  final TextStyle? videoDurationTextStyle;

  /// Style for the dialog title text (e.g. "Permission Required").
  final TextStyle? dialogTitleTextStyle;

  /// Style for the dialog body / content text.
  final TextStyle? dialogContentTextStyle;

  /// Style for the cancel action button inside dialogs.
  final TextStyle? dialogCancelTextStyle;

  /// Style for the confirm / open-settings action button inside dialogs.
  final TextStyle? dialogConfirmTextStyle;

  /// Style for the text inside the snack-bar notification.
  final TextStyle? snackBarTextStyle;

  /// Legacy style kept for compatibility – prefer the specific styles above.
  final TextStyle? customTextStyle;

  /// @deprecated – use [albumNameTextStyle] instead.
  final TextStyle? headerTextStyle;

  /// @deprecated – use [albumNameTextStyle] on the dropdown instead.
  final TextStyle? dropdownTextStyle;

  const HQPickerTheme({
    this.backgroundColor = const Color(0xFF121212),
    this.appbarColor = const Color(0xCC1C1C1E),
    this.bottomBarColor = const Color(0xCC1C1C1E),
    this.primaryColor = const Color(0xFF1C1C1E),
    this.confirmButtonColor = const Color(0xFF007AFF),
    this.confirmTextColor = Colors.white,
    this.textColor = Colors.white,
    this.iconCameraColor = Colors.white,
    this.iconGalleryColor = const Color(0xFF8E8E93),
    this.indicatorColor = const Color(0xFF007AFF),
    this.emptyListTextColor = const Color(0xFF8E8E93),
    this.backgroundDropDownColor = const Color(0xFF1C1C1E),
    this.textSelectedListAssetColor = Colors.white,
    this.badgeBackgroundColor = const Color(0xFF007AFF),
    this.badgeTextColor = Colors.white,
    this.selectedItemOverlayColor = Colors.black38,
    // text styles – all optional, fall back to color-based defaults
    this.confirmButtonTextStyle,
    this.albumNameTextStyle,
    this.albumCountTextStyle,
    this.emptyListTextStyle,
    this.badgeTextStyle,
    this.videoDurationTextStyle,
    this.dialogTitleTextStyle,
    this.dialogContentTextStyle,
    this.dialogCancelTextStyle,
    this.dialogConfirmTextStyle,
    this.snackBarTextStyle,
    this.customTextStyle,
    this.headerTextStyle,
    this.dropdownTextStyle,
  });

  // ── Resolved helpers (fall back to color-based defaults) ─────────────────

  TextStyle get resolvedConfirmButtonTextStyle =>
      confirmButtonTextStyle ?? TextStyle(color: confirmTextColor);

  TextStyle get resolvedAlbumNameTextStyle =>
      albumNameTextStyle ??
      headerTextStyle ??
      TextStyle(color: textColor, fontSize: 22.0);

  TextStyle get resolvedAlbumCountTextStyle =>
      albumCountTextStyle ?? TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 12.0);

  TextStyle get resolvedEmptyListTextStyle =>
      emptyListTextStyle ?? TextStyle(color: emptyListTextColor, fontSize: 18.0);

  TextStyle get resolvedBadgeTextStyle =>
      badgeTextStyle ?? TextStyle(color: badgeTextColor);

  TextStyle get resolvedVideoDurationTextStyle =>
      videoDurationTextStyle ??
      const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold);

  TextStyle get resolvedDialogTitleTextStyle =>
      dialogTitleTextStyle ?? TextStyle(color: textColor);

  TextStyle get resolvedDialogContentTextStyle =>
      dialogContentTextStyle ?? TextStyle(color: textColor);

  TextStyle get resolvedDialogCancelTextStyle =>
      dialogCancelTextStyle ?? TextStyle(color: textColor);

  TextStyle get resolvedDialogConfirmTextStyle =>
      dialogConfirmTextStyle ?? TextStyle(color: confirmButtonColor);

  TextStyle get resolvedSnackBarTextStyle =>
      snackBarTextStyle ?? TextStyle(color: textColor);

  // ── copyWith ─────────────────────────────────────────────────────────────

  HQPickerTheme copyWith({
    Color? backgroundColor,
    Color? appbarColor,
    Color? bottomBarColor,
    Color? primaryColor,
    Color? confirmButtonColor,
    Color? confirmTextColor,
    Color? textColor,
    Color? iconCameraColor,
    Color? iconGalleryColor,
    Color? indicatorColor,
    Color? emptyListTextColor,
    Color? backgroundDropDownColor,
    Color? textSelectedListAssetColor,
    Color? badgeBackgroundColor,
    Color? badgeTextColor,
    Color? selectedItemOverlayColor,
    TextStyle? confirmButtonTextStyle,
    TextStyle? albumNameTextStyle,
    TextStyle? albumCountTextStyle,
    TextStyle? emptyListTextStyle,
    TextStyle? badgeTextStyle,
    TextStyle? videoDurationTextStyle,
    TextStyle? dialogTitleTextStyle,
    TextStyle? dialogContentTextStyle,
    TextStyle? dialogCancelTextStyle,
    TextStyle? dialogConfirmTextStyle,
    TextStyle? snackBarTextStyle,
    TextStyle? customTextStyle,
    TextStyle? headerTextStyle,
    TextStyle? dropdownTextStyle,
  }) {
    return HQPickerTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      appbarColor: appbarColor ?? this.appbarColor,
      bottomBarColor: bottomBarColor ?? this.bottomBarColor,
      primaryColor: primaryColor ?? this.primaryColor,
      confirmButtonColor: confirmButtonColor ?? this.confirmButtonColor,
      confirmTextColor: confirmTextColor ?? this.confirmTextColor,
      textColor: textColor ?? this.textColor,
      iconCameraColor: iconCameraColor ?? this.iconCameraColor,
      iconGalleryColor: iconGalleryColor ?? this.iconGalleryColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      emptyListTextColor: emptyListTextColor ?? this.emptyListTextColor,
      backgroundDropDownColor: backgroundDropDownColor ?? this.backgroundDropDownColor,
      textSelectedListAssetColor: textSelectedListAssetColor ?? this.textSelectedListAssetColor,
      badgeBackgroundColor: badgeBackgroundColor ?? this.badgeBackgroundColor,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
      selectedItemOverlayColor: selectedItemOverlayColor ?? this.selectedItemOverlayColor,
      confirmButtonTextStyle: confirmButtonTextStyle ?? this.confirmButtonTextStyle,
      albumNameTextStyle: albumNameTextStyle ?? this.albumNameTextStyle,
      albumCountTextStyle: albumCountTextStyle ?? this.albumCountTextStyle,
      emptyListTextStyle: emptyListTextStyle ?? this.emptyListTextStyle,
      badgeTextStyle: badgeTextStyle ?? this.badgeTextStyle,
      videoDurationTextStyle: videoDurationTextStyle ?? this.videoDurationTextStyle,
      dialogTitleTextStyle: dialogTitleTextStyle ?? this.dialogTitleTextStyle,
      dialogContentTextStyle: dialogContentTextStyle ?? this.dialogContentTextStyle,
      dialogCancelTextStyle: dialogCancelTextStyle ?? this.dialogCancelTextStyle,
      dialogConfirmTextStyle: dialogConfirmTextStyle ?? this.dialogConfirmTextStyle,
      snackBarTextStyle: snackBarTextStyle ?? this.snackBarTextStyle,
      customTextStyle: customTextStyle ?? this.customTextStyle,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      dropdownTextStyle: dropdownTextStyle ?? this.dropdownTextStyle,
    );
  }
}
