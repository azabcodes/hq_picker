import 'hq_picker_theme.dart';
import 'hq_picker_localizations.dart';

class HQPickerConfig {
  final HQPickerTheme theme;
  final HQPickerLocalizations localizations;
  final bool enableCropping;
  final bool compressImage;
  final int compressQuality;

  const HQPickerConfig({
    this.theme = const HQPickerTheme(),
    this.localizations = const HQPickerLocalizations(),
    this.enableCropping = false,
    this.compressImage = true,
    this.compressQuality = 80,
  });
}
