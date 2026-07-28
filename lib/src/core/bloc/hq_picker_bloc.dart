import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../tools/media_services.dart';
import 'hq_picker_event.dart';
import 'hq_picker_state.dart';

class HQPickerBloc extends Bloc<HQPickerEvent, HQPickerState> {
  HQPickerBloc() : super(const HQPickerState()) {
    on<LoadAlbumsEvent>(_onLoadAlbums);
    on<ChangeAlbumEvent>(_onChangeAlbum);
    on<LoadMoreAssetsEvent>(_onLoadMoreAssets);
    on<SelectEntityEvent>(_onSelectEntity);
    on<ToggleAssetSelectionEvent>(_onToggleAssetSelection);
    on<SetSelectedAssetsEvent>(_onSetSelectedAssets);
    on<SetCapturedImageEvent>(_onSetCapturedImage);
    on<ToggleMultipleSelectionEvent>(_onToggleMultipleSelection);
    on<ToggleSheetEvent>(_onToggleSheet);
    on<SetMediaTypeEvent>(_onSetMediaType);
    on<UpdateScrollSizeEvent>(_onUpdateScrollSize);
    on<SetFilesEvent>(_onSetFiles);
    on<ToggleFileSelectionEvent>(_onToggleFileSelection);
    on<LoadAudioFilesEvent>(_onLoadAudioFiles);
    on<LoadDeviceFilesEvent>(_onLoadDeviceFiles);
  }

  Future<void> _onLoadAudioFiles(LoadAudioFilesEvent event, Emitter<HQPickerState> emit) async {
    if (state.audioFiles.isNotEmpty) return;
    emit(state.copyWith(status: HQPickerStatus.loading));
    try {
      final audioFiles = await HQPickerMediaServices.fetchFilesByExtensions([
        '.mp3',
        '.m4a',
        '.wav',
        '.aac',
        '.ogg',
        '.wma',
        '.flac',
      ]);
      emit(state.copyWith(audioFiles: audioFiles, status: HQPickerStatus.success));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), status: HQPickerStatus.failure));
    }
  }

  Future<void> _onLoadDeviceFiles(LoadDeviceFilesEvent event, Emitter<HQPickerState> emit) async {
    if (state.deviceFiles.isNotEmpty) return;
    emit(state.copyWith(status: HQPickerStatus.loading));
    try {
      final deviceFiles = await HQPickerMediaServices.fetchFilesByExtensions([
        '.pdf',
        '.doc',
        '.docx',
        '.xls',
        '.xlsx',
        '.ppt',
        '.pptx',
        '.txt',
      ]);
      emit(state.copyWith(deviceFiles: deviceFiles, status: HQPickerStatus.success));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), status: HQPickerStatus.failure));
    }
  }

  void _onSetFiles(SetFilesEvent event, Emitter<HQPickerState> emit) {
    if (event.audioFiles.isNotEmpty) {
      emit(state.copyWith(audioFiles: event.audioFiles));
    }
    if (event.deviceFiles.isNotEmpty) {
      emit(state.copyWith(deviceFiles: event.deviceFiles));
    }
  }

  void _onToggleFileSelection(ToggleFileSelectionEvent event, Emitter<HQPickerState> emit) {
    final List<FileSystemEntity> updatedList = List.from(state.selectedFiles);
    if (updatedList.contains(event.file)) {
      updatedList.remove(event.file);
    } else if (updatedList.length < event.maxCount) {
      updatedList.add(event.file);
    }
    emit(state.copyWith(selectedFiles: updatedList));
  }

  void _onToggleSheet(ToggleSheetEvent event, Emitter<HQPickerState> emit) {
    emit(
      state.copyWith(
        isDraggableOpen: !state.isDraggableOpen,
        isFile: false,
        isVideo: false,
        isAudio: false,
      ),
    );
  }

  void _onSetMediaType(SetMediaTypeEvent event, Emitter<HQPickerState> emit) {
    emit(
      state.copyWith(
        isFile: event.isFile,
        isVideo: event.isVideo,
        isAudio: event.isAudio,
      ),
    );
    if (event.isAudio && state.audioFiles.isEmpty) {
      add(const LoadAudioFilesEvent());
    }
    if (event.isFile && state.deviceFiles.isEmpty) {
      add(const LoadDeviceFilesEvent());
    }
  }

  void _onUpdateScrollSize(UpdateScrollSizeEvent event, Emitter<HQPickerState> emit) {
    emit(state.copyWith(scrollSize: event.size));
  }

  void _onSetCapturedImage(SetCapturedImageEvent event, Emitter<HQPickerState> emit) {
    emit(state.copyWith(capturedImage: () => event.image));
  }

  Future<void> _onLoadAlbums(LoadAlbumsEvent event, Emitter<HQPickerState> emit) async {
    emit(state.copyWith(status: HQPickerStatus.loading));
    try {
      final albums = await HQPickerMediaServices.loadAlbums(event.requestType);

      if (albums.isEmpty) {
        emit(
          state.copyWith(
            status: HQPickerStatus.success,
            albumList: [],
            assetsList: [],
            hasMore: false,
          ),
        );
        return;
      }

      List<int> fileCounts = [];
      List<Uint8List?> firstImages = [];

      if (event.fetchFileCounts) {
        for (var album in albums) {
          final count = await album.assetCountAsync;
          fileCounts.add(count);
          Uint8List? firstImageBytes;
          final firstAssets = await album.getAssetListRange(start: 0, end: 1);
          if (firstAssets.isNotEmpty) {
            firstImageBytes = await firstAssets.first.thumbnailDataWithSize(
              const ThumbnailSize.square(100),
            );
          }
          firstImages.add(firstImageBytes);
        }
      }

      final selectedAlbum = albums.first;

      emit(
        state.copyWith(
          albumList: albums,
          selectedAlbum: selectedAlbum,
          albumFileCounts: fileCounts,
          albumFirstImages: firstImages,
        ),
      );

      add(ChangeAlbumEvent(selectedAlbum));
    } catch (e) {
      emit(
        state.copyWith(
          status: HQPickerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onChangeAlbum(ChangeAlbumEvent event, Emitter<HQPickerState> emit) async {
    emit(
      state.copyWith(
        selectedAlbum: event.album,
        currentPage: 0,
        hasMore: true,
        isLoadingMore: false,
        status: HQPickerStatus.loading,
      ),
    );

    try {
      final assets = await HQPickerMediaServices.loadAssetsPaged(
        event.album,
        0,
        state.pageSize,
      );

      emit(
        state.copyWith(
          status: HQPickerStatus.success,
          assetsList: assets,
          selectedEntity: () => assets.isNotEmpty ? assets.first : null,
          hasMore: assets.length == state.pageSize,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HQPickerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMoreAssets(LoadMoreAssetsEvent event, Emitter<HQPickerState> emit) async {
    if (state.isLoadingMore || !state.hasMore || state.selectedAlbum == null) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final assets = await HQPickerMediaServices.loadAssetsPaged(
        state.selectedAlbum!,
        nextPage,
        state.pageSize,
      );

      emit(
        state.copyWith(
          currentPage: nextPage,
          assetsList: List.of(state.assetsList)..addAll(assets),
          hasMore: assets.length == state.pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSelectEntity(SelectEntityEvent event, Emitter<HQPickerState> emit) {
    emit(state.copyWith(selectedEntity: () => event.entity));
  }

  void _onToggleAssetSelection(ToggleAssetSelectionEvent event, Emitter<HQPickerState> emit) {
    final currentList = List<AssetEntity>.from(state.selectedAssetList);
    if (currentList.contains(event.entity)) {
      currentList.remove(event.entity);
    } else {
      if (currentList.length < event.maxCount) {
        currentList.add(event.entity);
      }
    }
    emit(state.copyWith(selectedAssetList: currentList));
  }

  void _onSetSelectedAssets(SetSelectedAssetsEvent event, Emitter<HQPickerState> emit) {
    emit(state.copyWith(selectedAssetList: event.assets));
  }

  void _onToggleMultipleSelection(ToggleMultipleSelectionEvent event, Emitter<HQPickerState> emit) {
    emit(
      state.copyWith(
        isMultiple: !state.isMultiple,
        selectedAssetList: [], // Clear selection when toggling
      ),
    );
  }
}
