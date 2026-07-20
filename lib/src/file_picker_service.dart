import 'package:file_selector/file_selector.dart';

class HQPickerFilePicker {
  /// Picks a generic file (e.g. text file)
  static Future<String?> pickDocumentFile({
    List<String>? allowedExtensions,
  }) async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'documents',
      extensions: allowedExtensions,
    );
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    return file?.path;
  }

  /// Picks a directory path
  static Future<String?> pickDirectoryPath() async {
    return await getDirectoryPath();
  }
}
