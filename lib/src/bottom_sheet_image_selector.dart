import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hq_picker/hq_picker.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:image_picker/image_picker.dart';

import 'bloc/hq_picker_bloc.dart';
import 'bloc/hq_picker_event.dart';
import 'bloc/hq_picker_state.dart';

class HQPickerBottomSheetImageSelector extends StatelessWidget {
  final int maxCount;
  final HQPickerRequestType requestType;
  final String confirmText;
  final String textEmptyList;
  final Color? confirmButtonColor;
  final Color confirmTextColor;
  final Color? backgroundColor;
  final Color? textEmptyListColor;
  final Color? backgroundSnackBarColor;
  final Color? dropdownColor;
  final TextStyle textStyleDropdown;
  final Widget iconCamera;
  final Widget? loading;
  final HQPickerCameraImageSettings? cameraImageSettings;

  const HQPickerBottomSheetImageSelector({
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
            fetchFileCounts: false,
          ),
        ),
      child: _HQPickerBottomSheetImageSelectorView(widget: this),
    );
  }
}

class _HQPickerBottomSheetImageSelectorView extends StatelessWidget {
  final HQPickerBottomSheetImageSelector widget;

  const _HQPickerBottomSheetImageSelectorView({required this.widget});

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

      if (context.mounted) {
        context.read<HQPickerBloc>().add(SetCapturedImageEvent(image));
        if (isSaved) {
          context.read<HQPickerBloc>().add(
            LoadAlbumsEvent(
              requestType: widget.requestType,
              fetchFileCounts: false,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<HQPickerBloc, HQPickerState>(
      builder: (context, state) {
        return SizedBox(
          height: size.height * 0.95,
          child: Scaffold(
            backgroundColor: widget.backgroundColor ?? Colors.grey.shade300,
            appBar: AppBar(
              actions: [
                TextButton(
                  onPressed: () {
                    if (state.selectedAssetList.isNotEmpty) {
                      Navigator.pop(context, state.selectedAssetList);
                    } else if (state.capturedImage != null) {
                      Navigator.pop(context, state.capturedImage);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor:
                              widget.backgroundSnackBarColor ?? Theme.of(context).primaryColor,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: SizedBox(
                height: size.height * 0.40,
                child: state.capturedImage != null
                    ? Image.file(
                        fit: BoxFit.cover,
                        height: size.height,
                        width: size.width,
                        state.capturedImage!,
                      )
                    : (state.selectedEntity == null)
                    ? const SizedBox.shrink()
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: AssetEntityImage(
                              state.selectedEntity!,
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
                          if (state.selectedEntity!.type == AssetType.video)
                            const Positioned.fill(
                              child: Center(
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 50.0,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            bottomSheet: SingleChildScrollView(
              child: SizedBox(
                width: size.width,
                height: size.height * 0.6,
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
                                items: state.albumList.map<DropdownMenuItem<AssetPathEntity>>((
                                  AssetPathEntity album,
                                ) {
                                  return DropdownMenuItem<AssetPathEntity>(
                                    value: album,
                                    child: Text(
                                      album.name == 'Recent' ? 'All' : album.name,
                                      style: widget.textStyleDropdown,
                                    ),
                                  );
                                }).toList(),
                              ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => pickImageCamera(context, ImageSource.camera),
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
                                              widget.textEmptyListColor ??
                                              Theme.of(context).primaryColor,
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
                                  itemCount:
                                      state.assetsList.length + (state.isLoadingMore ? 1 : 0),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 3,
                                    mainAxisSpacing: 3,
                                    mainAxisExtent: 100,
                                    childAspectRatio: 5.0,
                                  ),
                                  itemBuilder: (context, index) {
                                    if (index == state.assetsList.length) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (index < state.assetsList.length) {
                                      AssetEntity assetEntity = state.assetsList[index];
                                      return assetWidget(
                                        context,
                                        assetEntity,
                                        widget.maxCount,
                                        state,
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        context.read<HQPickerBloc>().add(SetCapturedImageEvent(null));
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
              color: assetEntity == state.selectedEntity && state.capturedImage == null
                  ? Colors.white60
                  : Colors.transparent,
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                context.read<HQPickerBloc>().add(ToggleAssetSelectionEvent(assetEntity, maxCount));
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
