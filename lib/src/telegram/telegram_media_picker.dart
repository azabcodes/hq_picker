// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../core/bloc/hq_picker_bloc.dart';
import '../core/bloc/hq_picker_event.dart';
import '../core/bloc/hq_picker_state.dart';
import '../core/components/camera_image_setting.dart';
import '../core/components/defult_builder_widget.dart';
import '../core/config/hq_picker_config.dart';
import '../core/tools/media_services.dart';
import '../core/tools/theme_generator.dart';

export '../core/components/camera_image_setting.dart';

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
  final HQPickerConfig config;

  HQPickerTelegramMediaPickers({
    super.key,
    required this.maxCountPickMedia,
    this.requestType = HQPickerRequestType.all,
    this.isRealCameraView = true,
    this.config = const HQPickerConfig(),
    String? textEmptyListVideo,
    String? textEmptyList,
    String? textEmptyListFile,
    String? textEmptyListAudio,
    this.confirmTextColor = Colors.black,
    this.backgroundColor,
    this.confirmButtonColor,
    this.textEmptyListColor,
    this.backgroundSnackBarColor,
    this.dropdownColor,
    this.primeryColor,
    this.onMediaPicked,
    this.maxCountPickFiles = 5,
    this.cameraImageSettings,
    this.textStyleEmptyListText = const TextStyle(color: Colors.grey, fontSize: 18),
    Widget? iconCamera,
    this.loading,
  }) : textEmptyListVideo = textEmptyListVideo ?? config.localizations.emptyListVideo,
       textEmptyList = textEmptyList ?? config.localizations.emptyList,
       textEmptyListFile = textEmptyListFile ?? config.localizations.emptyListFile,
       textEmptyListAudio = textEmptyListAudio ?? config.localizations.emptyListAudio,
       iconCamera = iconCamera ?? config.icons.camera;

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

    primaryColor = widget.primeryColor ?? widget.config.theme.primaryColor;
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
                              return HQPickerDefultBuilderWidget(
                                widget: widget,
                                controller: scrollController,
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
                                          icon: IconTheme(
                                            data: IconThemeData(color: theme.colorScheme.onPrimary),
                                            child: widget.config.icons.back,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        BlocBuilder<HQPickerBloc, HQPickerState>(
                                          builder: (context, state) {
                                            final albumName =
                                                (state.selectedAlbum != null &&
                                                    state.selectedAlbum!.name == 'Recent')
                                                ? widget.config.localizations.gallery
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
                                                    style: widget
                                                        .config
                                                        .theme
                                                        .resolvedAlbumNameTextStyle,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  IconTheme(
                                                    data: IconThemeData(
                                                      color: theme.colorScheme.onPrimary,
                                                      size: 28,
                                                    ),
                                                    child: widget.config.icons.dropdown,
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

  void _showAlbumSelector(BuildContext parentContext, HQPickerBloc bloc) {
    OverlayEntry? albumOverlayEntry;
    final controller = ScrollController();

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
                      child: SizedBox(
                        width: 320,
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            clipBehavior: Clip.antiAlias,
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
                                                imageFilter: ImageFilter.blur(
                                                  sigmaX: 1.0,
                                                  sigmaY: 1.0,
                                                ),
                                                child: Image(
                                                  fit: BoxFit.cover,
                                                  image: MemoryImage(firstImage),
                                                  width: 25,
                                                  height: 25,
                                                ),
                                              ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 15.0),
                                                child: Text(
                                                  album.name == 'Recent'
                                                      ? widget.config.localizations.gallery
                                                      : album.name,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: widget
                                                      .config
                                                      .theme
                                                      .resolvedAlbumNameTextStyle
                                                      .copyWith(fontSize: 16.0),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '$count',
                                              style:
                                                  widget.config.theme.resolvedAlbumCountTextStyle,
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
