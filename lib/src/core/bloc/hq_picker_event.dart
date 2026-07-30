import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

import '../tools/media_services.dart';

import '../config/hq_picker_config.dart';

abstract class HQPickerEvent extends Equatable {
  const HQPickerEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlbumsEvent extends HQPickerEvent {
  final HQPickerRequestType requestType;
  final bool fetchFileCounts;
  final HQPickerSortOrder sortOrder;

  const LoadAlbumsEvent({
    required this.requestType,
    this.fetchFileCounts = false,
    this.sortOrder = HQPickerSortOrder.newestFirst,
  });

  @override
  List<Object?> get props => [requestType, fetchFileCounts, sortOrder];
}

class ChangeAlbumEvent extends HQPickerEvent {
  final AssetPathEntity album;

  const ChangeAlbumEvent(this.album);

  @override
  List<Object?> get props => [album];
}

class LoadMoreAssetsEvent extends HQPickerEvent {}

class SelectEntityEvent extends HQPickerEvent {
  final AssetEntity entity;

  const SelectEntityEvent(this.entity);

  @override
  List<Object?> get props => [entity];
}

class ToggleAssetSelectionEvent extends HQPickerEvent {
  final AssetEntity entity;
  final int maxCount;

  const ToggleAssetSelectionEvent(this.entity, this.maxCount);

  @override
  List<Object?> get props => [entity, maxCount];
}

class SetSelectedAssetsEvent extends HQPickerEvent {
  final List<AssetEntity> assets;

  const SetSelectedAssetsEvent(this.assets);

  @override
  List<Object?> get props => [assets];
}

class SetCapturedImageEvent extends HQPickerEvent {
  final File? image;

  const SetCapturedImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class ToggleSheetEvent extends HQPickerEvent {
  const ToggleSheetEvent();

  @override
  List<Object?> get props => [];
}

class SetMediaTypeEvent extends HQPickerEvent {
  final bool isFile;
  final bool isVideo;
  final bool isAudio;

  const SetMediaTypeEvent({this.isFile = false, this.isVideo = false, this.isAudio = false});

  @override
  List<Object?> get props => [isFile, isVideo, isAudio];
}

class UpdateScrollSizeEvent extends HQPickerEvent {
  final double size;

  const UpdateScrollSizeEvent(this.size);

  @override
  List<Object?> get props => [size];
}

class SetFilesEvent extends HQPickerEvent {
  final List<FileSystemEntity> audioFiles;
  final List<FileSystemEntity> deviceFiles;

  const SetFilesEvent({this.audioFiles = const [], this.deviceFiles = const []});

  @override
  List<Object?> get props => [audioFiles, deviceFiles];
}

class ToggleFileSelectionEvent extends HQPickerEvent {
  final FileSystemEntity file;
  final int maxCount;

  const ToggleFileSelectionEvent(this.file, this.maxCount);

  @override
  List<Object?> get props => [file, maxCount];
}

class LoadAudioFilesEvent extends HQPickerEvent {
  const LoadAudioFilesEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeviceFilesEvent extends HQPickerEvent {
  const LoadDeviceFilesEvent();

  @override
  List<Object?> get props => [];
}

class ToggleMultipleSelectionEvent extends HQPickerEvent {}

/// Sets [isMultiple] directly (used at picker initialization based on maxCount).
/// Unlike [ToggleMultipleSelectionEvent], this does NOT clear the selected assets.
class InitMultipleSelectionEvent extends HQPickerEvent {
  final bool isMultiple;

  const InitMultipleSelectionEvent({required this.isMultiple});

  @override
  List<Object?> get props => [isMultiple];
}
