import 'package:flutter/material.dart';

class HQPickerThemeGenerator {
  // Create custom theme using user-supplied base color or default
  static ThemeData generateTheme({Color? primaryColor}) {
    primaryColor = primaryColor ?? const Color(0xFF2C2C2C);

    // Default colors for other sections

    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: primaryColor,
    );
  }
}
