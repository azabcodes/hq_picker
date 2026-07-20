// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import 'bloc/hq_picker_bloc.dart';
import 'bloc/hq_picker_event.dart';
import 'bloc/hq_picker_state.dart';
import 'tools/media_services.dart';
import 'tools/theme_generator.dart';
import 'widget/global/camera_image_setting.dart';
import 'widget/telegram/audio_telegram_widget.dart';
import 'widget/telegram/defult_builder_widget.dart';
import 'widget/telegram/file_device_widget.dart';
import 'widget/telegram/video_telegram_widget.dart';

export 'widget/global/camera_image_setting.dart';

late ThemeData theme;

typedef OnMediaPicked = void Function(List<AssetEntity>? assets, List<FileSystemEntity>? files);

class HQPickerTelegramMediaPickers extends StatefulWidget {
  final int maxCountPickMedia;
  final HQPickerRequestType requestType;
  final bool isRealCameraView;
  final String textEmptyListVideo;
  final String textEmptyList;
  final String textEmptyListFile;
  final String textEmptyListAudio;
  final TextStyle textStyleEmptyListText;
  final Color? confirmButtonColor;
  final Color confirmTextColor;
  final Color? backgroundColor;
  final Color? textEmptyListColor;
  final Color? backgroundSnackBarColor;
  final Color? dropdownColor;
  final Color? primeryColor;
  final Widget iconCamera;
  final Widget? loading;
  final OnMediaPicked? onMediaPicked;
  final int maxCountPickFiles;
  final HQPickerCameraImageSettings? cameraImageSettings;

  const HQPickerTelegramMediaPickers({
    super.key,
    required this.maxCountPickMedia,
    this.requestType = HQPickerRequestType.all,
    this.isRealCameraView = true,
    this.textEmptyListVideo = 'No video found.',
    this.textEmptyList = 'No albums found.',
    this.textEmptyListFile = 'No files found.',
    this.textEmptyListAudio = 'No audio found.',
    this.confirmTextColor = Colors.black,
    this.backgroundColor,
    this.confirmButtonColor,
    this.textEmptyListColor,
    this.backgroundSnackBarColor,
    this.dropdownColor,
    this.primeryColor = const Color(0xFF2C2C2C),
    this.onMediaPicked,
    this.maxCountPickFiles = 5,
    this.cameraImageSettings,
    this.textStyleEmptyListText = const TextStyle(color: Colors.grey, fontSize: 18),
    this.iconCamera = const Icon(Icons.camera, color: Colors.black),
    this.loading,
  });

  @override
  State<HQPickerTelegramMediaPickers> createState() => HQPickerTelegramMediaPickersState();
}

class HQPickerTelegramMediaPickersState extends State<HQPickerTelegramMediaPickers> {
  late final HQPickerBloc _bloc;
  OverlayEntry? _overlayEntry;
  late DraggableScrollableController _controller;
  late Color primaryColor;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();

    _bloc = HQPickerBloc()
      ..add(LoadAlbumsEvent(requestType: widget.requestType, fetchFileCounts: true));

    _controller.addListener(() {
      _bloc.add(UpdateScrollSizeEvent(_controller.size));
    });

    primaryColor = widget.primeryColor ?? const Color(0xFF2C2C2C);
    theme = HQPickerThemeGenerator.generateTheme(primaryColor: primaryColor);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bloc.close();
    _overlayEntry?.remove();
    super.dispose();
  }

  void toggleSheet(BuildContext context) {
    if (_bloc.state.isDraggableOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _bloc.add(const ToggleSheetEvent());
    } else {
      _bloc.add(const ToggleSheetEvent());
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  OverlayEntry _createOverlayEntry(BuildContext parentContext) {
    return OverlayEntry(
      builder: (context) => BlocProvider.value(
        value: _bloc,
        child: Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                toggleSheet(parentContext);
              },
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                  SafeArea(
                    child: Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                              _bloc.add(LoadMoreAssetsEvent());
                            }
                            return false;
                          },
                          child: DraggableScrollableSheet(
                            controller: _controller,
                            initialChildSize: 0.5,
                            minChildSize: 0.2,
                            maxChildSize: 1.0,
                            builder: (context, scrollController) {
                              return BlocBuilder<HQPickerBloc, HQPickerState>(
                                buildWhen: (previous, current) {
                                  return previous.isFile != current.isFile ||
                                      previous.isVideo != current.isVideo ||
                                      previous.isAudio != current.isAudio;
                                },
                                builder: (context, state) {
                                  if (state.isFile) {
                                    return HQPickerFileListScreen(
                                      scrollController: scrollController,
                                      overlayEntry: _overlayEntry!,
                                      maxCountPickFiles: widget.maxCountPickFiles,
                                      textEmptyListFile: widget.textEmptyListFile,
                                      textStyleEmptyListText: widget.textStyleEmptyListText,
                                      toggleSheet: () => toggleSheet(parentContext),
                                      onFilesSelected: (assets, selectedFiles) {
                                        widget.onMediaPicked?.call(null, selectedFiles);
                                      },
                                    );
                                  } else if (state.isVideo) {
                                    return HQPickerVideoOnlyPage(
                                      widget: widget,
                                      controller: scrollController,
                                      maxCountPickFiles: widget.maxCountPickFiles,
                                      overlayEntry: _overlayEntry!,
                                      toggleSheet: () => toggleSheet(parentContext),
                                      onFilesSelected: (assets, selectedFiles) {
                                        widget.onMediaPicked?.call(assets, null);
                                      },
                                    );
                                  } else if (state.isAudio) {
                                    return HQPickerAudioTelegramWidget(
                                      scrollController: scrollController,
                                      maxCountPickFiles: widget.maxCountPickFiles,
                                      overlayEntry: _overlayEntry!,
                                      textEmptyListAudio: widget.textEmptyListAudio,
                                      textStyleEmptyListText: widget.textStyleEmptyListText,
                                      toggleSheet: () => toggleSheet(parentContext),
                                      onFilesSelected: (assets, selectedFiles) {
                                        widget.onMediaPicked?.call(null, selectedFiles);
                                      },
                                    );
                                  } else {
                                    return HQPickerDefultBuilderWidget(
                                      widget: widget,
                                      controller: scrollController,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),

                        // App bar that appears when the sheet is near the top
                        BlocSelector<HQPickerBloc, HQPickerState, double>(
                          selector: (state) => state.scrollSize,
                          builder: (context, size) {
                            final showAppBar = size > 0.9;
                            return Positioned(
                              top: 0,
                              right: 0,
                              left: 0,
                              child: AnimatedOpacity(
                                opacity: showAppBar ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 400),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  height: showAppBar
                                      ? MediaQuery.of(context).size.height * 0.075
                                      : 0,
                                  color: theme.primaryColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () => toggleSheet(parentContext),
                                          icon: Icon(
                                            Icons.arrow_back_ios_new,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        BlocBuilder<HQPickerBloc, HQPickerState>(
                                          builder: (context, state) {
                                            final albumName =
                                                (state.selectedAlbum != null &&
                                                    state.selectedAlbum!.name == 'Recent')
                                                ? 'Gallery'
                                                : (state.selectedAlbum?.name ?? '');
                                            return InkWell(
                                              onTap: () {
                                                if (showAppBar) {
                                                  _showAlbumSelector(parentContext, _bloc);
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    albumName,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22.0,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Icon(
                                                    Icons.keyboard_arrow_down_sharp,
                                                    color: theme.colorScheme.onPrimary,
                                                    size: 28,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Bottom bar
                        BlocSelector<HQPickerBloc, HQPickerState, double>(
                          selector: (state) => state.scrollSize,
                          builder: (context, size) {
                            final showBottomBar = size < 0.9;
                            return Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: AnimatedOpacity(
                                opacity: showBottomBar ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: showBottomBar
                                      ? MediaQuery.of(context).size.height * 0.095
                                      : 0,
                                  color: theme.primaryColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildBottomBarItem(
                                          context,
                                          CupertinoIcons.doc,
                                          'File',
                                          isFile: true,
                                          isVideo: false,
                                          isAudio: false,
                                        ),
                                        _buildBottomBarItem(
                                          context,
                                          CupertinoIcons.film,
                                          'Video',
                                          isFile: false,
                                          isVideo: true,
                                          isAudio: false,
                                        ),
                                        _buildBottomBarItem(
                                          context,
                                          CupertinoIcons.music_albums_fill,
                                          'Audio',
                                          isFile: false,
                                          isVideo: false,
                                          isAudio: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarItem(
    BuildContext context,
    IconData icon,
    String label, {
    required bool isFile,
    required bool isVideo,
    required bool isAudio,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          _bloc.add(SetMediaTypeEvent(isFile: isFile, isVideo: isVideo, isAudio: isAudio));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.onPrimary, size: 28),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 14.0)),
          ],
        ),
      ),
    );
  }

  void _showAlbumSelector(BuildContext parentContext, HQPickerBloc bloc) {
    OverlayEntry? albumOverlayEntry;
    ScrollController controller = ScrollController();

    albumOverlayEntry = OverlayEntry(
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) {
              return;
            }
            albumOverlayEntry?.remove();
          },
          child: GestureDetector(
            onTap: () {
              albumOverlayEntry?.remove();
            },
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    left: 25,
                    top: 50,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 320,
                        height: MediaQuery.of(context).size.height * 0.85,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: BlocBuilder<HQPickerBloc, HQPickerState>(
                            builder: (context, state) {
                              return ListView.builder(
                                controller: controller,
                                physics: const BouncingScrollPhysics(),
                                itemCount: state.albumList.length,
                                itemBuilder: (context, index) {
                                  final album = state.albumList[index];
                                  final count = state.albumFileCounts.length > index
                                      ? state.albumFileCounts[index]
                                      : 0;
                                  final firstImage = state.albumFirstImages.length > index
                                      ? state.albumFirstImages[index]
                                      : null;

                                  return ListTile(
                                    onTap: () {
                                      bloc.add(ChangeAlbumEvent(album));
                                      albumOverlayEntry?.remove();
                                    },
                                    title: Row(
                                      children: [
                                        if (firstImage != null)
                                          ImageFiltered(
                                            imageFilter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                                            child: Image(
                                              fit: BoxFit.cover,
                                              image: FileImage(firstImage),
                                              width: 25,
                                              height: 25,
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15.0),
                                          child: Text(
                                            album.name == 'Recent' ? 'Gallery' : album.name,
                                            style: TextStyle(
                                              color: theme.colorScheme.onPrimary,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$count',
                                          style: TextStyle(
                                            color: theme.primaryColorLight,
                                            fontWeight: FontWeight.w500,
                                            fontSize: theme.textTheme.bodySmall?.fontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(parentContext).insert(albumOverlayEntry);
  }
}
