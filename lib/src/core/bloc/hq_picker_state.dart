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

  /// Precomputed lookup structures for [selectedAssetList].
  ///
  /// Every visible grid tile reads "is this asset selected" and "what's its
  /// selection number" once per build. Previously those were derived live
  /// (`selectedAssetList.map((e) => e.id).toSet()` and `List.indexOf`), which
  /// meant every tile paid an O(selection count) cost on every rebuild —
  /// O(visible tiles × selections) overall. These are now computed exactly
  /// once, whenever [selectedAssetList] actually changes (see [copyWith]),
  /// and simply reused otherwise.
  final Set<String> selectedAssetIdsSet;
  final Map<String, int> selectedAssetIndexById;

  /// Internal constructor — all fields (including the derived selection
  /// lookups) must be supplied explicitly and consistently. Prefer the
  /// [HQPickerState.new] factory or [copyWith] instead of calling this
  /// directly.
  const HQPickerState._raw({
    required this.status,
    required this.albumList,
    required this.selectedAlbum,
    required this.assetsList,
    required this.selectedAssetList,
    required this.selectedEntity,
    required this.currentPage,
    required this.isLoadingMore,
    required this.hasMore,
    required this.pageSize,
    required this.albumFileCounts,
    required this.albumFirstImages,
    required this.errorMessage,
    required this.capturedImage,
    required this.isDraggableOpen,
    required this.isFile,
    required this.isVideo,
    required this.isAudio,
    required this.isMultiple,
    required this.scrollSize,
    required this.selectedFiles,
    required this.audioFiles,
    required this.deviceFiles,
    required this.selectedAssetIdsSet,
    required this.selectedAssetIndexById,
  });

  factory HQPickerState({
    HQPickerStatus status = HQPickerStatus.initial,
    List<AssetPathEntity> albumList = const [],
    AssetPathEntity? selectedAlbum,
    List<AssetEntity> assetsList = const [],
    List<AssetEntity> selectedAssetList = const [],
    AssetEntity? selectedEntity,
    int currentPage = 0,
    bool isLoadingMore = false,
    bool hasMore = true,
    int pageSize = 60,
    List<int> albumFileCounts = const [],
    List<Uint8List?> albumFirstImages = const [],
    String? errorMessage,
    File? capturedImage,
    bool isDraggableOpen = false,
    bool isFile = false,
    bool isVideo = false,
    bool isAudio = false,
    bool isMultiple = false,
    double scrollSize = 0.5,
    List<FileSystemEntity> selectedFiles = const [],
    List<FileSystemEntity> audioFiles = const [],
    List<FileSystemEntity> deviceFiles = const [],
  }) {
    return HQPickerState._raw(
      status: status,
      albumList: albumList,
      selectedAlbum: selectedAlbum,
      assetsList: assetsList,
      selectedAssetList: selectedAssetList,
      selectedEntity: selectedEntity,
      currentPage: currentPage,
      isLoadingMore: isLoadingMore,
      hasMore: hasMore,
      pageSize: pageSize,
      albumFileCounts: albumFileCounts,
      albumFirstImages: albumFirstImages,
      errorMessage: errorMessage,
      capturedImage: capturedImage,
      isDraggableOpen: isDraggableOpen,
      isFile: isFile,
      isVideo: isVideo,
      isAudio: isAudio,
      isMultiple: isMultiple,
      scrollSize: scrollSize,
      selectedFiles: selectedFiles,
      audioFiles: audioFiles,
      deviceFiles: deviceFiles,
      selectedAssetIdsSet: _buildIdSet(selectedAssetList),
      selectedAssetIndexById: _buildIndexMap(selectedAssetList),
    );
  }

  static Set<String> _buildIdSet(List<AssetEntity> list) {
    if (list.isEmpty) return const {};
    return list.map((e) => e.id).toSet();
  }

  static Map<String, int> _buildIndexMap(List<AssetEntity> list) {
    if (list.isEmpty) return const {};
    final map = <String, int>{};
    for (var i = 0; i < list.length; i++) {
      map[list[i].id] = i;
    }
    return map;
  }

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
    final newSelectedAssetList = selectedAssetList ?? this.selectedAssetList;
    // Only recompute the derived lookup structures when the selection list
    // is actually being replaced — every other state change (paging in more
    // assets, switching albums, toggling loading flags, etc.) reuses the
    // existing Set/Map for free.
    final selectionChanged =
        selectedAssetList != null && !identical(selectedAssetList, this.selectedAssetList);

    return HQPickerState._raw(
      status: status ?? this.status,
      albumList: albumList ?? this.albumList,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      assetsList: assetsList ?? this.assetsList,
      selectedAssetList: newSelectedAssetList,
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
      selectedAssetIdsSet: selectionChanged
          ? _buildIdSet(newSelectedAssetList)
          : selectedAssetIdsSet,
      selectedAssetIndexById: selectionChanged
          ? _buildIndexMap(newSelectedAssetList)
          : selectedAssetIndexById,
    );
  }

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
