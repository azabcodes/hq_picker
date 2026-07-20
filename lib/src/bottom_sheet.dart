import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:hq_picker/hq_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'bloc/hq_picker_bloc.dart';
import 'bloc/hq_picker_event.dart';
import 'bloc/hq_picker_state.dart';

class HQPickerBottomSheets extends StatelessWidget {
  /// The maximum allowed number of selected items.
  final int maxCount;

  /// The type of request specifying what data is needed.
  final HQPickerRequestType requestType;

  /// The text displayed on the confirmation button.
  final String confirmText;

  /// The text displayed when the list is empty.
  final String textEmptyList;

  /// The color of the confirmation button (optional).
  final Color? confirmButtonColor;

  /// The text color of the confirmation button.
  final Color confirmTextColor;

  /// The background color of the bottom sheet (optional).
  final Color? backgroundColor;

  /// The text color when the list is empty (optional).
  final Color? textEmptyListColor;

  /// The background color of the snackBar (optional).
  final Color? backgroundSnackBarColor;

  /// The background color of the dropdown menu (optional).
  final Color? dropdownColor;

  /// The text style of the dropdown menu.
  final TextStyle textStyleDropdown;

  /// The icon displayed for the camera button.
  final Widget iconCamera;

  /// A custom loading widget (optional).
  final Widget? loading;

  /// The settings for camera image capture (optional).
  final HQPickerCameraImageSettings? cameraImageSettings;

  /// Constructor for the HQPickerBottomSheets class.
  const HQPickerBottomSheets({
    super.key,
    required this.maxCount,
    required this.requestType,
    this.confirmText = 'Send',
    this.textEmptyList = 'No albums found.',
    this.confirmTextColor = Colors.black,
    this.backgroundColor,
    this.confirmButtonColor,
    this.textEmptyListColor,
    this.backgroundSnackBarColor,
    this.dropdownColor,
    this.cameraImageSettings,
    this.iconCamera = const Icon(Icons.camera, color: Colors.black),
    this.textStyleDropdown = const TextStyle(fontSize: 18, color: Colors.black),
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HQPickerBloc()
        ..add(
          LoadAlbumsEvent(
            requestType: requestType,
            fetchFileCounts: true,
          ),
        ),
      child: _HQPickerBottomSheetsView(widget: this),
    );
  }
}

class _HQPickerBottomSheetsView extends StatelessWidget {
  final HQPickerBottomSheets widget;

  const _HQPickerBottomSheetsView({required this.widget});

  Future<void> pickImageCamera(BuildContext context, ImageSource source) async {
    final myFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: widget.cameraImageSettings?.imageQuality,
      preferredCameraDevice: widget.cameraImageSettings?.preferredCameraDevice ?? CameraDevice.rear,
      maxWidth: widget.cameraImageSettings?.maxWidth,
      maxHeight: widget.cameraImageSettings?.maxHeight,
    );

    bool isSaved = false;
    if (myFile != null) {
      File image = File(myFile.path);
      if (Platform.isAndroid) {
        isSaved = await FlutterSaver.saveImageAndroid(fileImage: image);
      } else {
        isSaved = await FlutterSaver.saveImageIos(fileImage: image);
      }

      debugPrint('Image saved: $isSaved');

      if (isSaved) {
        if (context.mounted) {
          context.read<HQPickerBloc>().add(
            LoadAlbumsEvent(
              requestType: widget.requestType,
              fetchFileCounts: true,
            ),
          );
        }
      } else {
        debugPrint('Error: Image was not saved.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<HQPickerBloc, HQPickerState>(
      builder: (context, state) {
        return Container(
          width: size.width,
          height: size.height * 0.80,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Theme.of(context).primaryColorLight,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14.0),
              topRight: Radius.circular(14.0),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 50.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      if (state.selectedAlbum != null)
                        DropdownButton<AssetPathEntity>(
                          underline: const SizedBox.shrink(),
                          icon: const SizedBox.shrink(),
                          dropdownColor: widget.dropdownColor ?? Theme.of(context).cardColor,
                          value: state.selectedAlbum,
                          onChanged: (AssetPathEntity? value) {
                            if (value != null) {
                              context.read<HQPickerBloc>().add(ChangeAlbumEvent(value));
                            }
                          },
                          items: state.albumList
                              .asMap()
                              .entries
                              .map<DropdownMenuItem<AssetPathEntity>>((
                                entry,
                              ) {
                                int index = entry.key;
                                AssetPathEntity album = entry.value;
                                return DropdownMenuItem<AssetPathEntity>(
                                  value: album,
                                  child: Row(
                                    children: [
                                      if (state.albumFirstImages.length > index &&
                                          state.albumFirstImages[index] != null)
                                        ImageFiltered(
                                          imageFilter: ImageFilter.blur(
                                            sigmaX: 1.0,
                                            sigmaY: 1.0,
                                          ),
                                          child: Image(
                                            fit: BoxFit.cover,
                                            image: FileImage(
                                              state.albumFirstImages[index]!,
                                            ),
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        album.name == 'Recent' ? 'All' : album.name,
                                        style: widget.textStyleDropdown,
                                      ),
                                      const SizedBox(width: 8),
                                      if (state.albumFileCounts.length > index)
                                        Text(
                                          '(${state.albumFileCounts[index]})',
                                          style: widget.textStyleDropdown,
                                        ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          await pickImageCamera(context, ImageSource.camera);
                        },
                        icon: widget.iconCamera,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: state.assetsList.isEmpty
                      ? Center(
                          child: state.status == HQPickerStatus.loading
                              ? widget.loading ?? const CircularProgressIndicator.adaptive()
                              : Text(
                                  widget.textEmptyList,
                                  style: TextStyle(
                                    color:
                                        widget.textEmptyListColor ?? Theme.of(context).primaryColor,
                                    fontSize:
                                        Theme.of(
                                          context,
                                        ).primaryTextTheme.headlineMedium?.fontSize ??
                                        20,
                                  ),
                                ),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                              context.read<HQPickerBloc>().add(LoadMoreAssetsEvent());
                            }
                            return false;
                          },
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: state.assetsList.length + (state.isLoadingMore ? 1 : 0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 3,
                              mainAxisSpacing: 3,
                              mainAxisExtent: 100,
                            ),
                            itemBuilder: (context, index) {
                              if (index == state.assetsList.length) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (index < state.assetsList.length) {
                                AssetEntity assetEntity = state.assetsList[index];
                                return assetWidget(context, assetEntity, widget.maxCount, state);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                ),
              ),
              state.assetsList.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 1.0),
                      child: MaterialButton(
                        color: widget.confirmButtonColor ?? Theme.of(context).primaryColorLight,
                        height: 55,
                        minWidth: size.width * 0.98,
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.merge(
                            BorderSide.none,
                            BorderSide.none,
                          ),
                        ),
                        onPressed: () {
                          if (state.selectedAssetList.isNotEmpty) {
                            Navigator.pop(context, state.selectedAssetList);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor:
                                    widget.backgroundSnackBarColor ??
                                    Theme.of(context).primaryColor,
                                margin: const EdgeInsets.all(15.0),
                                behavior: SnackBarBehavior.floating,
                                shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                content: const Text('No image selected'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          widget.confirmText,
                          style: TextStyle(
                            color: widget.confirmTextColor,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget assetWidget(
    BuildContext context,
    AssetEntity assetEntity,
    int maxCount,
    HQPickerState state,
  ) {
    bool isSelected = state.selectedAssetList.contains(assetEntity);
    return GestureDetector(
      onTap: () {
        context.read<HQPickerBloc>().add(SelectEntityEvent(assetEntity));
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: AssetEntityImage(
              assetEntity,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize.square(250),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ),
          if (assetEntity.type == AssetType.video)
            const Positioned.fill(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.video_library_outlined, color: Colors.red),
                ),
              ),
            ),
          Positioned.fill(
            child: Container(
              color: assetEntity == state.selectedEntity ? Colors.white60 : Colors.transparent,
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                context.read<HQPickerBloc>().add(ToggleAssetSelectionEvent(assetEntity, maxCount));
                context.read<HQPickerBloc>().add(SelectEntityEvent(assetEntity));
              },
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white12,
                      shape: BoxShape.circle,
                      border: Border.all(width: 1.5, color: Colors.white),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        '${state.selectedAssetList.indexOf(assetEntity) + 1}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
