import 'package:flutter/material.dart';

class HQPickerTheme {
  final Color backgroundColor;
  final Color appbarColor;
  final Color bottomBarColor;
  final Color confirmButtonColor;
  final Color confirmTextColor;
  final Color textColor;
  final Color iconCameraColor;
  final Color iconGalleryColor;
  final Color indicatorColor;
  final Color emptyListTextColor;
  final Color backgroundDropDownColor;
  final Color textSelectedListAssetColor;
  final TextStyle? customTextStyle;

  const HQPickerTheme({
    this.backgroundColor = const Color(0xFF2A2D3E),
    this.appbarColor = const Color(0xFF2A2D3E),
    this.bottomBarColor = const Color(0xFF2A2D3E),
    this.confirmButtonColor = Colors.blue,
    this.confirmTextColor = Colors.white,
    this.textColor = Colors.white,
    this.iconCameraColor = Colors.white,
    this.iconGalleryColor = Colors.white,
    this.indicatorColor = Colors.blue,
    this.emptyListTextColor = Colors.white,
    this.backgroundDropDownColor = const Color(0xFF2A2D3E),
    this.textSelectedListAssetColor = Colors.white,
    this.customTextStyle,
  });
}
