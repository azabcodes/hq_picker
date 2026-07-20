import 'package:image_picker/image_picker.dart';

/// The `HQPickerCameraImageSettings` class provides configurable settings
/// for capturing images from the device's camera.
///
/// It allows customization of image quality, selection of the preferred
/// camera device (front or rear), and setting maximum dimensions for the
/// captured images.
///
/// ### Constructor Parameters:
///
/// - `imageQuality`: Defines the quality of the captured image.
///   - Value: `int` (0-100, default: null)
///   - Higher values produce better quality images, but result in larger file sizes.
///
/// - `preferredCameraDevice`: Specifies whether to use the front or rear camera.
///   - Value: `CameraDevice` (default: `CameraDevice.rear`)
///   - Can be set to `CameraDevice.front` for front-facing camera.
///
/// - `maxWidth`: Sets the maximum width for the captured image.
///   - Value: `double` (default: null)
///   - Images wider than this value will be resized to fit.
///
/// - `maxHeight`: Sets the maximum height for the captured image.
///   - Value: `double` (default: null)
///   - Images taller than this value will be resized to fit.
///
/// ### Example Usage:
///
/// ```dart
/// HQPickerCameraImageSettings imageSettings = HQPickerCameraImageSettings(
///   imageQuality: 90,
///   preferredCameraDevice: CameraDevice.front,
///   maxWidth: 1024,
///   maxHeight: 1024,
/// );
/// ```
///
/// This class is particularly useful when you need to balance image quality and file size,
/// or when you need to ensure consistent image dimensions across different devices.
class HQPickerCameraImageSettings {
  final int? imageQuality;
  final CameraDevice preferredCameraDevice;
  final double? maxWidth;
  final double? maxHeight;

  HQPickerCameraImageSettings({
    this.imageQuality,
    this.preferredCameraDevice = CameraDevice.rear,
    this.maxWidth,
    this.maxHeight,
  });
}
