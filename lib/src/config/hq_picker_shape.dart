/// Defines all supported UI picker shapes and styles in [HQPicker].
enum HQPickerShape {
  /// Full-screen Instagram preview & grid picker style.
  instagram,

  /// Custom picker layout with TabBar (Images & Videos tabs).
  custom,

  /// Standard modal bottom sheet picker style.
  bottomSheet,

  /// Full-height Scaffold bottom sheet style with header and action buttons.
  scaffoldBottomSheet,

  /// Image selector modal bottom sheet with album dropdown selector.
  bottomSheetImageSelector,

  /// Telegram-style sliding media sheet with camera, gallery, audio, and file tabs.
  telegram,

  /// Native platform document picker.
  document,

  /// Native platform directory/folder picker.
  directory,
}
