import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

enum HQPickerStatus { initial, loading, success, failure }

class HQPickerState extends Equatable {
  final HQPickerStatus status;
  final List<AssetPathEntity> albumList;
  final AssetPathEntity? selectedAlbum;
  final List<AssetEntity> assetsList;
  final List<AssetEntity> selectedAssetList;
  final AssetEntity? selectedEntity;

  final int currentPage;
  final bool isLoadingMore;
  final bool hasMore;
  final int pageSize;

  final List<int> albumFileCounts;
  final List<Uint8List?> albumFirstImages;

  final String? errorMessage;
  final File? capturedImage;

  final bool isDraggableOpen;
  final bool isFile;
  final bool isVideo;
  final bool isAudio;
  final bool isMultiple;
  final double scrollSize;

  final List<FileSystemEntity> selectedFiles;
  final List<FileSystemEntity> audioFiles;
  final List<FileSystemEntity> deviceFiles;

  const HQPickerState({
    this.status = HQPickerStatus.initial,
    this.albumList = const [],
    this.selectedAlbum,
    this.assetsList = const [],
    this.selectedAssetList = const [],
    this.selectedEntity,
    this.currentPage = 0,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.pageSize = 60,
    this.albumFileCounts = const [],
    this.albumFirstImages = const [],
    this.errorMessage,
    this.capturedImage,
    this.isDraggableOpen = false,
    this.isFile = false,
    this.isVideo = false,
    this.isAudio = false,
    this.isMultiple = false,
    this.scrollSize = 0.5,
    this.selectedFiles = const [],
    this.audioFiles = const [],
    this.deviceFiles = const [],
  });

  HQPickerState copyWith({
    HQPickerStatus? status,
    List<AssetPathEntity>? albumList,
    AssetPathEntity? selectedAlbum,
    List<AssetEntity>? assetsList,
    List<AssetEntity>? selectedAssetList,
    AssetEntity? Function()? selectedEntity,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
    int? pageSize,
    List<int>? albumFileCounts,
    List<Uint8List?>? albumFirstImages,
    String? errorMessage,
    File? Function()? capturedImage,
    bool? isDraggableOpen,
    bool? isFile,
    bool? isVideo,
    bool? isAudio,
    bool? isMultiple,
    double? scrollSize,
    List<FileSystemEntity>? selectedFiles,
    List<FileSystemEntity>? audioFiles,
    List<FileSystemEntity>? deviceFiles,
  }) {
    return HQPickerState(
      status: status ?? this.status,
      albumList: albumList ?? this.albumList,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      assetsList: assetsList ?? this.assetsList,
      selectedAssetList: selectedAssetList ?? this.selectedAssetList,
      selectedEntity: selectedEntity != null ? selectedEntity() : this.selectedEntity,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      pageSize: pageSize ?? this.pageSize,
      albumFileCounts: albumFileCounts ?? this.albumFileCounts,
      albumFirstImages: albumFirstImages ?? this.albumFirstImages,
      errorMessage: errorMessage ?? this.errorMessage,
      capturedImage: capturedImage != null ? capturedImage() : this.capturedImage,
      isDraggableOpen: isDraggableOpen ?? this.isDraggableOpen,
      isFile: isFile ?? this.isFile,
      isVideo: isVideo ?? this.isVideo,
      isAudio: isAudio ?? this.isAudio,
      isMultiple: isMultiple ?? this.isMultiple,
      scrollSize: scrollSize ?? this.scrollSize,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      audioFiles: audioFiles ?? this.audioFiles,
      deviceFiles: deviceFiles ?? this.deviceFiles,
    );
  }

  Set<String> get selectedAssetIdsSet => selectedAssetList.map((e) => e.id).toSet();

  @override
  List<Object?> get props => [
    status,
    albumList,
    selectedAlbum,
    assetsList,
    selectedAssetList,
    selectedEntity,
    currentPage,
    isLoadingMore,
    hasMore,
    pageSize,
    albumFileCounts,
    albumFirstImages,
    errorMessage,
    capturedImage,
    isDraggableOpen,
    isFile,
    isVideo,
    isAudio,
    isMultiple,
    scrollSize,
    selectedFiles,
    audioFiles,
    deviceFiles,
  ];
}
