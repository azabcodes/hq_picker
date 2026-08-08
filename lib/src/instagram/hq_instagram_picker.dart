// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:image_picker/image_picker.dart';

import '../../hq_picker.dart';
import '../core/bloc/hq_picker_bloc.dart';
import '../core/bloc/hq_picker_event.dart';
import '../core/bloc/hq_picker_state.dart';

/// Instagram-style full-screen media picker.
///
/// Shows a large preview on top and a 4-column asset grid below.
/// Use [HQPicker.instagramPicker] or [HQPicker.pick] instead of
/// instantiating this widget directly.
///
/// Multi-select mode is determined automatically: if [maxCount] > 1, multi-select
/// is enabled; otherwise single-select mode is used.
class HQInstagramPicker extends StatefulWidget {
  final int maxCount;
  final HQPickerRequestType requestType;
  final HQPickerConfig config;
  final Widget? loading;
  final Widget? title;
  final HQPickerCameraImageSettings? cameraImageSettings;

  // ── Legacy color/text params (still forwarded for BC) ───────────────────
  final String textEmptyList;
  final Color? textEmptyListColor;

  const HQInstagramPicker({
    super.key,
    required this.maxCount,
    required this.requestType,
    this.config = const HQPickerConfig(),
    this.loading,
    this.title,
    this.cameraImageSettings,
    this.textEmptyList = 'No albums found.',
    this.textEmptyListColor,
  });

  @override
  State<HQInstagramPicker> createState() => _HQInstagramPickerState();
}

class _HQInstagramPickerState extends State<HQInstagramPicker> with AutomaticKeepAliveClientMixin {
  late final HQPickerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = HQPickerBloc()
      ..add(
        LoadAlbumsEvent(
          requestType: widget.requestType,
          fetchFileCounts: false,
          sortOrder: widget.config.sortOrder,
        ),
      )
      ..add(InitMultipleSelectionEvent(isMultiple: widget.maxCount > 1));
  }

  @override
  void didUpdateWidget(covariant HQInstagramPicker oldWidget) {
    if (oldWidget.requestType != widget.requestType) {
      _bloc.add(
        LoadAlbumsEvent(
          requestType: widget.requestType,
          fetchFileCounts: false,
          sortOrder: widget.config.sortOrder,
        ),
      );
    }
    if (oldWidget.maxCount != widget.maxCount) {
      _bloc.add(InitMultipleSelectionEvent(isMultiple: widget.maxCount > 1));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // NOTE: previously called PhotoManager.clearFileCache() here. That wipes
    // the *entire* app-wide thumbnail cache every time a single picker
    // instance closes, forcing every thumbnail (in this picker or any other
    // photo_manager consumer) to be re-decoded from scratch next time. If a
    // hard cache reset is genuinely needed for a specific product reason,
    // do it explicitly at that call site instead of unconditionally here.
    _bloc.close();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      XFile? pickedFile;
      if (widget.requestType == HQPickerRequestType.video) {
        pickedFile = await ImagePicker().pickVideo(
          source: source,
          preferredCameraDevice:
              widget.cameraImageSettings?.preferredCameraDevice ?? CameraDevice.rear,
        );
      } else {
        pickedFile = await ImagePicker().pickImage(
          source: source,
          imageQuality: widget.cameraImageSettings?.imageQuality,
          preferredCameraDevice:
              widget.cameraImageSettings?.preferredCameraDevice ?? CameraDevice.rear,
          maxWidth: widget.cameraImageSettings?.maxWidth,
          maxHeight: widget.cameraImageSettings?.maxHeight,
        );
      }

      if (pickedFile != null) {
        final mediaFile = File(pickedFile.path);
        _bloc.add(SetCapturedImageEvent(mediaFile));

        try {
          if (widget.requestType != HQPickerRequestType.video) {
            if (Platform.isAndroid) {
              await FlutterSaver.saveImageAndroid(fileImage: mediaFile);
            } else if (Platform.isIOS) {
              await FlutterSaver.saveImageIos(fileImage: mediaFile);
            }
          }
        } catch (e) {
          debugPrint('Save to gallery error: $e');
        }

        _bloc.add(LoadAlbumsEvent(requestType: widget.requestType, fetchFileCounts: false));
      }
    } on PlatformException catch (error) {
      debugPrint('PlatformException: $error');
    } catch (error) {
      debugPrint('Error picking media: $error');
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, HQPickerState state) {
    List<AssetEntity> selectedAssets = [];
    if (state.selectedAssetList.isEmpty && state.selectedEntity != null) {
      selectedAssets = [state.selectedEntity!];
    } else {
      selectedAssets = List.from(state.selectedAssetList);
    }

    void handleConfirm() {
      if (selectedAssets.isNotEmpty) {
        Navigator.pop(context, selectedAssets);
      } else {
        widget.config.showSelectionError(
          context,
          widget.config.localizations.emptyList,
        );
      }
    }

    if (widget.config.appBarBuilder != null) {
      return widget.config.appBarBuilder!(
        context,
        state.selectedAlbum,
        selectedAssets,
        handleConfirm,
        () => Navigator.pop(context),
      );
    }

    return AppBar(
      backgroundColor: widget.config.theme.appbarColor,
      elevation: 0,
      leading: IconButton(
        icon: IconTheme(
          data: IconThemeData(color: widget.config.theme.textColor),
          child: widget.config.icons.back,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title:
          widget.title ??
          GestureDetector(
            onTap: () => _showAlbumSelector(context, state),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.selectedAlbum == null
                      ? widget.config.localizations.gallery
                      : (state.selectedAlbum!.name == 'Recent'
                            ? widget.config.localizations.gallery
                            : state.selectedAlbum!.name),
                  style: widget.config.theme.resolvedAlbumNameTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: widget.config.theme.textColor,
                  size: 22,
                ),
              ],
            ),
          ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Center(
            child: widget.config.confirmButtonBuilder != null
                ? widget.config.confirmButtonBuilder!(
                    context,
                    selectedAssets,
                    handleConfirm,
                  )
                : InkResponse(
                    onTap: handleConfirm,
                    child: Text(
                      widget.config.localizations.confirm,
                      style: widget.config.theme.resolvedConfirmButtonTextStyle,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<HQPickerBloc, HQPickerState>(
        // This screen never reads isDraggableOpen/isFile/isVideo/isAudio/
        // scrollSize/selectedFiles/audioFiles/deviceFiles (those only matter
        // to the Telegram bottom-sheet picker), so skip rebuilding the whole
        // Scaffold — including the grid and preview — when only those change.
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.albumList != current.albumList ||
            previous.selectedAlbum != current.selectedAlbum ||
            previous.assetsList != current.assetsList ||
            previous.selectedAssetList != current.selectedAssetList ||
            previous.selectedEntity != current.selectedEntity ||
            previous.isLoadingMore != current.isLoadingMore ||
            previous.hasMore != current.hasMore ||
            previous.capturedImage != current.capturedImage ||
            previous.isMultiple != current.isMultiple ||
            previous.errorMessage != current.errorMessage,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: widget.config.theme.backgroundColor,
            appBar: _buildAppBar(context, state),
            body: Column(
              children: [
                // ── Large preview with InteractiveViewer (Pinch to Zoom) ─────
                SizedBox(
                  height: size.height * 0.40,
                  child: state.capturedImage != null
                      ? InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          clipBehavior: Clip.hardEdge,
                          child: Image.file(
                            fit: BoxFit.cover,
                            height: size.height,
                            width: size.width,
                            state.capturedImage!,
                          ),
                        )
                      : (state.selectedEntity == null)
                      ? const SizedBox.shrink()
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: InteractiveViewer(
                                minScale: 1.0,
                                maxScale: 4.0,
                                clipBehavior: Clip.hardEdge,
                                child: AssetEntityImage(
                                  state.selectedEntity!,
                                  isOriginal: false,
                                  thumbnailSize: const ThumbnailSize.square(500),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: IconTheme(
                                        data: const IconThemeData(color: Colors.red),
                                        child: widget.config.icons.error,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (state.selectedEntity!.type == AssetType.video)
                              Positioned.fill(
                                child: Center(
                                  child: IconTheme(
                                    data: const IconThemeData(
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                    child: widget.config.icons.play,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Album toolbar / headerBuilder
                      if (widget.config.headerBuilder != null)
                        widget.config.headerBuilder!(
                          context,
                          state.selectedAlbum,
                          widget.config.albumFilter != null
                              ? state.albumList.where(widget.config.albumFilter!).toList()
                              : state.albumList,
                          (album) {
                            widget.config.onAlbumChanged?.call(album);
                            _bloc.add(ChangeAlbumEvent(album));
                          },
                        )
                      else
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: widget.config.theme.backgroundDropDownColor,
                          ),
                          child: Row(
                            children: [
                              if (state.selectedAlbum != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: GestureDetector(
                                    onTap: () => _showAlbumSelector(context, state),
                                    child: Row(
                                      children: [
                                        Text(
                                          state.selectedAlbum!.name == 'Recent'
                                              ? widget.config.localizations.recent
                                              : state.selectedAlbum!.name,
                                          style: widget.config.theme.resolvedAlbumNameTextStyle
                                              .copyWith(fontSize: 20.0),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5.0),
                                          child: IconTheme(
                                            data: IconThemeData(
                                              color: widget.config.theme.iconGalleryColor,
                                            ),
                                            child: widget.config.icons.dropdown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const Spacer(),

                              // ── Camera buttons (conditional on requestType) ─
                              if (widget.requestType == HQPickerRequestType.image ||
                                  widget.requestType == HQPickerRequestType.all)
                                IconButton(
                                  onPressed: () async => _pickMedia(ImageSource.camera),
                                  tooltip: 'Photo',
                                  icon: IconTheme(
                                    data: IconThemeData(
                                      color: widget.config.theme.iconCameraColor,
                                    ),
                                    child: widget.config.icons.camera,
                                  ),
                                ),
                              if (widget.requestType == HQPickerRequestType.video ||
                                  widget.requestType == HQPickerRequestType.all)
                                IconButton(
                                  onPressed: () async => _pickMedia(ImageSource.camera),
                                  tooltip: 'Video',
                                  icon: IconTheme(
                                    data: IconThemeData(
                                      color: widget.config.theme.iconCameraColor,
                                    ),
                                    child: widget.config.icons.cameraVideo,
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Asset grid
                      Flexible(
                        child: state.assetsList.isEmpty
                            ? (widget.config.emptyWidget ??
                                  Center(
                                    child: state.status == HQPickerStatus.loading
                                        ? widget.loading ??
                                              const CircularProgressIndicator.adaptive()
                                        : Text(
                                            widget.textEmptyList,
                                            style: widget.config.theme.resolvedEmptyListTextStyle,
                                          ),
                                  ))
                            : NotificationListener<ScrollNotification>(
                                onNotification: (ScrollNotification scrollInfo) {
                                  if (scrollInfo.metrics.pixels >=
                                      scrollInfo.metrics.maxScrollExtent - 200) {
                                    _bloc.add(LoadMoreAssetsEvent());
                                  }
                                  return false;
                                },
                                child: GridView.builder(
                                  physics:
                                      widget.config.scrollPhysics ??
                                      const BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                  scrollCacheExtent: const ScrollCacheExtent.pixels(1500.0),
                                  addRepaintBoundaries: true,
                                  addAutomaticKeepAlives: true,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: widget.config.gridCrossAxisCount ?? 4,
                                    mainAxisSpacing: widget.config.gridMainAxisSpacing,
                                    crossAxisSpacing: widget.config.gridCrossAxisSpacing,
                                    childAspectRatio: widget.config.gridChildAspectRatio,
                                  ),
                                  itemCount:
                                      state.assetsList.length + (state.isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index < state.assetsList.length) {
                                      final asset = state.assetsList[index];
                                      return HQAssetItem(
                                        key: ValueKey(asset.id),
                                        assetEntity: asset,
                                        state: state,
                                        maxCount: widget.maxCount,
                                        config: widget.config,
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator.adaptive(),
                                      );
                                    }
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAlbumSelector(BuildContext context, HQPickerState state) {
    final filteredAlbums = widget.config.albumFilter != null
        ? state.albumList.where(widget.config.albumFilter!).toList()
        : state.albumList;

    showModalBottomSheet(
      backgroundColor: widget.config.theme.backgroundDropDownColor,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      builder: (_) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: filteredAlbums.length,
          itemBuilder: (context, index) {
            final album = filteredAlbums[index];
            return ListTile(
              onTap: () {
                widget.config.onAlbumChanged?.call(album);
                _bloc.add(ChangeAlbumEvent(album));
                Navigator.pop(context);
              },
              title: Text(
                album.name == 'Recent' ? widget.config.localizations.gallery : album.name,
                style: widget.config.theme.resolvedAlbumNameTextStyle.copyWith(
                  fontSize: 18.0,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
