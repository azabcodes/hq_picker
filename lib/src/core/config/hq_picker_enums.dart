/// Selection badge style displayed over assets in grid.
enum HQPickerSelectionStyle {
  /// Displays selection number (1, 2, 3...) inside badge.
  number,

  /// Displays check mark icon (✓) inside badge.
  checkMark,

  /// Shows a colored border highlight without badge icon/number.
  borderOnly,
}

/// Positioning of the selection badge over the asset tile.
enum HQPickerBadgePosition {
  topRight,
  topLeft,
  bottomRight,
  bottomLeft,
}

/// Preferred camera lens direction when opening in-app camera.
enum HQPickerCameraLens {
  back,
  front,
}

/// Mode of media capture supported in camera interface.
enum HQPickerCameraCaptureMode {
  all,
  photoOnly,
  videoOnly,
}

/// File list view layout mode (List vs Grid).
enum HQPickerFileViewMode {
  list,
  grid,
}

/// Gesture trigger action for double tap / long press on media tile.
enum HQPickerGestureAction {
  none,
  select,
  preview,
  showInfo,
}

