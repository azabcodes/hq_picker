import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HQPickerCameraPreviewWidget extends StatefulWidget {
  final Future<void> Function(ImageSource source) pickImageCamera;

  const HQPickerCameraPreviewWidget({super.key, required this.pickImageCamera});

  @override
  State<HQPickerCameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<HQPickerCameraPreviewWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.pickImageCamera(ImageSource.camera);
      },
      child: Stack(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CameraAwesomeBuilder.previewOnly(
                builder: (state, preview) {
                  return AspectRatio(
                    aspectRatio: preview.previewSize.aspectRatio,
                  );
                },
              ),
            ),
          ),
          Positioned(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                width: 150,
                height: 150,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.044,
            left: MediaQuery.of(context).size.width * 0.098,
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 50),
          ),
        ],
      ),
    );
  }
}

class HQPickerFackeCameraWidget extends StatelessWidget {
  final Future<void> Function(ImageSource source) pickImageCamera;
  const HQPickerFackeCameraWidget({super.key, required this.pickImageCamera});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        pickImageCamera(ImageSource.camera);
      },
      child: SizedBox(
        width: 150,
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            children: [
              Positioned(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.044,
                left: MediaQuery.of(context).size.width * 0.098,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
