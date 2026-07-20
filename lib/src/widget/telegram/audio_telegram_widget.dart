import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hq_picker/src/telegram_media_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path/path.dart' as path;

import '../../bloc/hq_picker_bloc.dart';
import '../../bloc/hq_picker_event.dart';
import '../../bloc/hq_picker_state.dart';

class HQPickerAudioTelegramWidget extends StatelessWidget {
  final ScrollController scrollController;
  final int maxCountPickFiles;
  final OnMediaPicked onFilesSelected;
  final OverlayEntry overlayEntry;
  final VoidCallback toggleSheet;
  final String textEmptyListAudio;
  final TextStyle textStyleEmptyListText;

  const HQPickerAudioTelegramWidget({
    super.key,
    required this.scrollController,
    required this.maxCountPickFiles,
    required this.onFilesSelected,
    required this.overlayEntry,
    required this.toggleSheet,
    required this.textEmptyListAudio,
    required this.textStyleEmptyListText,
  });

  void _sendSelectedFiles(BuildContext context, HQPickerState state) {
    onFilesSelected(null, state.selectedFiles);
    toggleSheet();
  }

  void _toggleSelection(BuildContext context, FileSystemEntity file) {
    context.read<HQPickerBloc>().add(ToggleFileSelectionEvent(file, maxCountPickFiles));
  }

  Widget getIconForFile(String fileExtension) {
    String normalizedExtension = fileExtension.startsWith('.') ? fileExtension : '.$fileExtension';

    Map<String, IconData> icons = {
      '.mp3': Icons.play_circle_fill,
      '.wav': Icons.play_circle_fill,
      '.aac': Icons.play_circle_fill,
      '.ogg': Icons.play_circle_fill,
      '.flac': Icons.play_circle_fill,
      '.amr': Icons.play_circle_fill,
      '.m4a': Icons.play_circle_fill,
      '.wma': Icons.play_circle_fill,
    };

    IconData iconData = icons.containsKey(normalizedExtension)
        ? icons[normalizedExtension]!
        : LucideIcons.file;

    int hash = normalizedExtension.hashCode;
    Color fixedColor = Color((hash & 0xFFFFFF) + 0xFF000000);

    return Icon(iconData, color: fixedColor);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HQPickerBloc, HQPickerState>(
      builder: (context, state) {
        if (state.status == HQPickerStatus.loading && state.audioFiles.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: const Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        if (state.audioFiles.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: Center(
              child: Text(
                textEmptyListAudio,
                style: textStyleEmptyListText,
              ),
            ),
          );
        }

        List<FileSystemEntity> files = state.audioFiles;

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      height: 7,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      color: theme.primaryColor,
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          FileSystemEntity file = files[index];
                          String fileExtension = path.extension(file.path).toLowerCase();
                          bool isSelected = state.selectedFiles.contains(file);

                          return InkWell(
                            onTap: () => _toggleSelection(context, file),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.primaryColorLight
                                    : theme.colorScheme.secondary,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                    offset: const Offset(2, 2),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                    offset: const Offset(-2, -2),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 35,
                                  height: 35,
                                  color: Colors.white,
                                  child: getIconForFile(fileExtension),
                                ),
                                title: Text(
                                  file.path.split('/').last,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.selectedFiles.isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.10,
                right: 30,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    InkResponse(
                      onTap: () {
                        _sendSelectedFiles(context, state);
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(Icons.send, color: theme.colorScheme.onPrimary),
                      ),
                    ),
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: Container(
                        alignment: Alignment.center,
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2.0),
                        ),
                        child: Text(
                          '${state.selectedFiles.length}',
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
