import 'package:flutter/material.dart';

/// Configurable icons for all UI elements across HQPicker.
class HQPickerIcons {
  final Widget camera;
  final Widget send;
  final Widget check;
  final Widget play;
  final Widget fileTab;
  final Widget videoTab;
  final Widget audioTab;
  final Widget dropdown;
  final Widget clear;
  final Widget error;
  final Widget back;

  const HQPickerIcons({
    this.camera = const Icon(Icons.camera_alt),
    this.send = const Icon(Icons.send),
    this.check = const Icon(Icons.check),
    this.play = const Icon(Icons.play_arrow),
    this.fileTab = const Icon(Icons.insert_drive_file),
    this.videoTab = const Icon(Icons.videocam),
    this.audioTab = const Icon(Icons.audiotrack),
    this.dropdown = const Icon(Icons.keyboard_arrow_down_sharp),
    this.clear = const Icon(Icons.close),
    this.error = const Icon(Icons.error),
    this.back = const Icon(Icons.arrow_back_ios_new),
  });

  HQPickerIcons copyWith({
    Widget? camera,
    Widget? send,
    Widget? check,
    Widget? play,
    Widget? fileTab,
    Widget? videoTab,
    Widget? audioTab,
    Widget? dropdown,
    Widget? clear,
    Widget? error,
    Widget? back,
  }) {
    return HQPickerIcons(
      camera: camera ?? this.camera,
      send: send ?? this.send,
      check: check ?? this.check,
      play: play ?? this.play,
      fileTab: fileTab ?? this.fileTab,
      videoTab: videoTab ?? this.videoTab,
      audioTab: audioTab ?? this.audioTab,
      dropdown: dropdown ?? this.dropdown,
      clear: clear ?? this.clear,
      error: error ?? this.error,
      back: back ?? this.back,
    );
  }
}
