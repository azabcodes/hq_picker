// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hq_picker/src/custom_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../bloc/hq_picker_bloc.dart';
import '../bloc/hq_picker_event.dart';
import '../bloc/hq_picker_state.dart';

class HQPickerImageWidget extends StatelessWidget {
  /// The size of the image widget.
  final Size size;

  /// The instance of HQPickerCustomPicker used within this widget.
  final HQPickerCustomPicker widget;

  /// Constructor for the HQPickerImageWidget class.
  const HQPickerImageWidget({
    super.key,
    required this.size,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HQPickerBloc, HQPickerState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: SizedBox(
              width: size.width,
              height: double.maxFinite,
              child: widget.showOnlyImage
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: state.assetsList.isEmpty
                          ? Center(
                              child: state.status == HQPickerStatus.loading
                                  ? const CircularProgressIndicator.adaptive()
                                  : Text(
                                      widget.textEmptyList,
                                      style: TextStyle(
                                        color: widget.textEmptyListColor,
                                        fontSize: 20,
                                      ),
                                    ),
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
                        style: TextStyle(
                          color: widget.textEmptyListColor,
                          fontSize: 20,
                        ),
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
          Positioned.fill(
            child: AssetEntityImage(
              assetEntity,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize.square(100),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
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
