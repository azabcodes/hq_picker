// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hq_picker/src/custom_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../bloc/hq_picker_bloc.dart';
import '../bloc/hq_picker_event.dart';
import '../bloc/hq_picker_state.dart';

class HQPickerVideoWidget extends StatelessWidget {
  /// The size of the video widget.
  final Size size;

  /// The instance of HQPickerCustomPicker used within this widget.
  final HQPickerCustomPicker widget;

  /// Constructor for the HQPickerVideoWidget class.
  const HQPickerVideoWidget({
    super.key,
    required this.size,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HQPickerBloc, HQPickerState>(
      builder: (context, state) {
        final videoAssets = state.assetsList
            .where((assetEntity) => assetEntity.type == AssetType.video)
            .toList();
        return SingleChildScrollView(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: widget.showOnlyVideo && videoAssets.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: state.assetsList.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: size.height * 0.4,
                                ),
                                child: Center(
                                  child: state.status == HQPickerStatus.loading
                                      ? const CircularProgressIndicator.adaptive()
                                      : Text(
                                          widget.textEmptyList,
                                          style: TextStyle(
                                            color: widget.textEmptyListColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          )
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: state.assetsList.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 3,
                              mainAxisSpacing: 3,
                              mainAxisExtent: 115,
                              childAspectRatio: 5.0,
                            ),
                            itemBuilder: (context, index) {
                              AssetEntity assetEntity = state.assetsList[index];
                              return assetWidget(
                                context,
                                assetEntity,
                                widget.maxCount,
                                state.selectedAssetList,
                              );
                            },
                          ),
                  )
                : Center(
                    child: Text(
                      widget.textEmptyList,
                      style: const TextStyle(
                        color: Color(0xFF6A0DAD),
                        fontSize: 20,
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
    List<AssetEntity> selectedAssetList,
  ) {
    bool isSelected = selectedAssetList.contains(assetEntity);

    return GestureDetector(
      onTap: () {
        context.read<HQPickerBloc>().add(ToggleAssetSelectionEvent(assetEntity, maxCount));
      },
      child: Stack(
        children: [
          (assetEntity.type == AssetType.video)
              ? Positioned.fill(
                  child: AssetEntityImage(
                    assetEntity,
                    thumbnailSize: const ThumbnailSize.square(250),
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                )
              : Container(),
          const Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.video_library_outlined, color: Colors.red),
              ),
            ),
          ),
          if (isSelected)
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  border: Border.all(width: 8, color: Colors.white70),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 30),
              ),
            ),
        ],
      ),
    );
  }
}
