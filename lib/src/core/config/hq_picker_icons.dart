import 'package:flutter/cupertino.dart';

/// Configurable icons for all UI elements across HQPicker.
class HQPickerIcons {
  final Widget camera;

  /// Icon for the video camera button in the Instagram picker toolbar.
  /// Shown only when [HQPickerRequestType] is `video` or `all`.
  final Widget cameraVideo;
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
  final Widget? gifBadge;

  const HQPickerIcons({
    this.camera = const Icon(CupertinoIcons.camera_fill),
    this.cameraVideo = const Icon(CupertinoIcons.videocam_fill),
    this.send = const Icon(CupertinoIcons.arrow_up_circle_fill),
    this.check = const Icon(CupertinoIcons.checkmark_alt),
    this.play = const Icon(CupertinoIcons.play_fill),
    this.fileTab = const Icon(CupertinoIcons.doc_fill),
    this.videoTab = const Icon(CupertinoIcons.videocam_fill),
    this.audioTab = const Icon(CupertinoIcons.music_note),
    this.dropdown = const Icon(CupertinoIcons.chevron_down),
    this.clear = const Icon(CupertinoIcons.xmark_circle_fill),
    this.error = const Icon(CupertinoIcons.exclamationmark_triangle_fill),
    this.back = const Icon(CupertinoIcons.chevron_back),
    this.gifBadge,
  });

  HQPickerIcons copyWith({
    Widget? camera,
    Widget? cameraVideo,
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
    Widget? gifBadge,
  }) {
    return HQPickerIcons(
      camera: camera ?? this.camera,
      cameraVideo: cameraVideo ?? this.cameraVideo,
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
      gifBadge: gifBadge ?? this.gifBadge,
    );
  }
}
