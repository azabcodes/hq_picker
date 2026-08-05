import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hq_picker/hq_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HQPicker Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
          secondaryContainer: Color(0xFF262626),
          onSecondaryContainer: Colors.white,
        ),
      ),
      home: const PickerHomePage(),
    );
  }
}

// ─────────────────────────────────────────────
// Shape Option Model
// ─────────────────────────────────────────────
class _ShapeOption {
  final String name;
  final String description;
  final IconData icon;
  final HQPickerShape shape;
  final bool isDirectory;

  const _ShapeOption({
    required this.name,
    required this.description,
    required this.icon,
    required this.shape,
    this.isDirectory = false,
  });
}

const List<_ShapeOption> _shapes = [
  _ShapeOption(
    name: 'Instagram Style',
    description: 'Full-screen preview grid layout',
    icon: Icons.camera_alt_outlined,
    shape: HQPickerShape.instagram,
  ),
  _ShapeOption(
    name: 'Telegram Sheet',
    description: 'Sliding Telegram-style media sheet',
    icon: Icons.send_rounded,
    shape: HQPickerShape.telegram,
  ),
  _ShapeOption(
    name: 'Document Picker',
    description: 'Native system document picker',
    icon: Icons.description_outlined,
    shape: HQPickerShape.document,
  ),
  _ShapeOption(
    name: 'Directory Picker',
    description: 'Native system folder picker',
    icon: Icons.folder_open_outlined,
    shape: HQPickerShape.directory,
    isDirectory: true,
  ),
];

// ─────────────────────────────────────────────
// Main Home Page
// ─────────────────────────────────────────────
class PickerHomePage extends StatefulWidget {
  const PickerHomePage({super.key});

  @override
  State<PickerHomePage> createState() => _PickerHomePageState();
}

class _PickerHomePageState extends State<PickerHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<HQPickerResult> _results = [];

  // ── Customization Settings State ──────────────────────────────────────────
  int _gridCrossAxisCount = 3;
  double _gridItemBorderRadius = 12.0;
  HQPickerSelectionStyle _selectionStyle = HQPickerSelectionStyle.checkMark;
  HQPickerBadgePosition _badgePosition = HQPickerBadgePosition.topRight;
  bool _enableFullScreenPreview = true;
  int _maxVideoDurationSeconds = 60;
  HQPickerFileViewMode _fileViewMode = HQPickerFileViewMode.list;
  HQPickerGestureAction _doubleTapAction = HQPickerGestureAction.none;
  HQPickerGestureAction _longPressAction = HQPickerGestureAction.preview;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCustomizationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '⚙️ Customization Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),

                    // Grid Columns
                    Text(
                      'Grid Columns: $_gridCrossAxisCount',
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: _gridCrossAxisCount.toDouble(),
                      min: 2,
                      max: 5,
                      divisions: 3,
                      activeColor: Colors.deepPurpleAccent,
                      label: '$_gridCrossAxisCount',
                      onChanged: (v) {
                        setModalState(() => _gridCrossAxisCount = v.toInt());
                        setState(() {});
                      },
                    ),

                    // Border Radius
                    Text(
                      'Border Radius: ${_gridItemBorderRadius.toInt()}px',
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: _gridItemBorderRadius,
                      min: 0,
                      max: 24,
                      divisions: 12,
                      activeColor: Colors.deepPurpleAccent,
                      label: '${_gridItemBorderRadius.toInt()}px',
                      onChanged: (v) {
                        setModalState(() => _gridItemBorderRadius = v);
                        setState(() {});
                      },
                    ),

                    // Selection Style
                    const Text(
                      'Selection Badge Style',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: HQPickerSelectionStyle.values.map((style) {
                        final isSel = _selectionStyle == style;
                        return ChoiceChip(
                          label: Text(style.name),
                          selected: isSel,
                          selectedColor: Colors.deepPurple,
                          onSelected: (sel) {
                            if (sel) {
                              setModalState(() => _selectionStyle = style);
                              setState(() {});
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Badge Position
                    const Text(
                      'Badge Position',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: HQPickerBadgePosition.values.map((pos) {
                        final isSel = _badgePosition == pos;
                        return ChoiceChip(
                          label: Text(pos.name),
                          selected: isSel,
                          selectedColor: Colors.deepPurple,
                          onSelected: (sel) {
                            if (sel) {
                              setModalState(() => _badgePosition = pos);
                              setState(() {});
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Fullscreen preview & Max video duration
                    SwitchListTile(
                      title: const Text('Full-Screen Preview (Long Press)',
                          style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Long press asset tile to inspect in full-screen',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                      value: _enableFullScreenPreview,
                      activeTrackColor: Colors.deepPurpleAccent,
                      onChanged: (v) {
                        setModalState(() => _enableFullScreenPreview = v);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 10),

                    Text(
                      'Max Video Duration: ${_maxVideoDurationSeconds}s',
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: _maxVideoDurationSeconds.toDouble(),
                      min: 15,
                      max: 180,
                      divisions: 11,
                      activeColor: Colors.deepPurpleAccent,
                      label: '${_maxVideoDurationSeconds}s',
                      onChanged: (v) {
                        setModalState(() => _maxVideoDurationSeconds = v.toInt());
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 12),

                    // File View Mode
                    const Text(
                      'File View Mode',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: HQPickerFileViewMode.values.map((mode) {
                        final isSel = _fileViewMode == mode;
                        return ChoiceChip(
                          label: Text(mode.name.toUpperCase()),
                          selected: isSel,
                          selectedColor: Colors.deepPurple,
                          onSelected: (sel) {
                            if (sel) {
                              setModalState(() => _fileViewMode = mode);
                              setState(() {});
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Double Tap Action
                    const Text(
                      'Double Tap Action',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: HQPickerGestureAction.values.map((act) {
                        final isSel = _doubleTapAction == act;
                        return ChoiceChip(
                          label: Text(act.name),
                          selected: isSel,
                          selectedColor: Colors.deepPurple,
                          onSelected: (sel) {
                            if (sel) {
                              setModalState(() => _doubleTapAction = act);
                              setState(() {});
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Long Press Action
                    const Text(
                      'Long Press Action',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: HQPickerGestureAction.values.map((act) {
                        final isSel = _longPressAction == act;
                        return ChoiceChip(
                          label: Text(act.name),
                          selected: isSel,
                          selectedColor: Colors.deepPurple,
                          onSelected: (sel) {
                            if (sel) {
                              setModalState(() => _longPressAction = act);
                              setState(() {});
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Apply Settings', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickMedia({
    required HQPickerShape shape,
    required int maxCount,
    required HQPickerRequestType requestType,
  }) async {
    try {
      List<String>? allowedExtensions;
      if (shape == HQPickerShape.document) {
        if (requestType == HQPickerRequestType.image) {
          allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'];
        } else if (requestType == HQPickerRequestType.video) {
          allowedExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'];
        }
      }

      final results = await HQPicker.pick(
        context: context,
        shape: shape,
        maxCount: maxCount,
        requestType: requestType,
        allowedExtensions: allowedExtensions,
        config: HQPickerConfig(
          compressImage: false,
          // ── Grid & Item Customization ─────────────────────
          gridCrossAxisCount: _gridCrossAxisCount,
          gridCrossAxisSpacing: 4.0,
          gridMainAxisSpacing: 4.0,
          gridItemBorderRadius: BorderRadius.circular(_gridItemBorderRadius),
          // ── Selection Badge & Animation Customization ──────
          selectionStyle: _selectionStyle,
          badgePosition: _badgePosition,
          enableSelectionAnimation: true,
          // ── Fullscreen Preview & Constraints ───────────────
          enableFullScreenPreview: _enableFullScreenPreview,
          maxVideoDuration: Duration(seconds: _maxVideoDurationSeconds),
          // ── File View Mode & Gestures ─────────────────────
          fileViewMode: _fileViewMode,
          doubleTapAction: _doubleTapAction,
          longPressAction: _longPressAction,
          customFileTypeIcons: {
            '.pdf': const Icon(Icons.picture_as_pdf, color: Colors.red),
            '.docx': const Icon(Icons.description, color: Colors.blue),
          },
          // ── Callbacks ─────────────────────────────────────
          onMaxCountReached: () {
            debugPrint('HQPicker: Max count limit reached!');
          },
          onAssetTap: (asset) {
            debugPrint('HQPicker: Asset tapped: ${asset.id}');
          },
          onAlbumChanged: (album) {
            debugPrint('HQPicker: Album changed: ${album.name}');
          },
          // ── Theming example ──────────────────────────────
          theme: HQPickerTheme(
            backgroundColor: const Color(0xFF1E1E2E),
            appbarColor: const Color(0xFF1E1E2E),
            backgroundDropDownColor: const Color(0xFF2A2D3E),
            confirmButtonColor: Colors.deepPurple,
            badgeBackgroundColor: Colors.deepPurple,
          ),
          // ── Localization example ──────────────────────────
          localizations: const HQPickerLocalizations(
            confirm: 'Done',
            emptyList: 'No media found',
            gallery: 'Gallery',
            permissionRequired: 'Access Required',
            permissionDenied: 'Please allow media access in Settings.',
          ),
          // ── Scroll physics, sort order & custom icons ──
          sortOrder: HQPickerSortOrder.newestFirst,
          scrollPhysics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          icons: HQPickerIcons(
            gifBadge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'GIF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // ── Custom snack-bar callback ─────────────────────
          onSnackBar: (ctx, msg) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.deepPurple,
              ),
            );
          },
          // ── Custom empty state widget ───────────────────
          emptyWidget: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.white54),
                SizedBox(height: 12),
                Text('No items found in this album', style: TextStyle(color: Colors.white54)),
              ],
            ),
          ),
        ),
      );

      if (!mounted) return;
      setState(() => _results = results);

      if (results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${results.length} item(s) selected'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearResults() {
    setState(() => _results = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HQPicker Example'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Customize Settings',
            onPressed: _openCustomizationBottomSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.image_outlined), text: 'Images'),
            Tab(icon: Icon(Icons.videocam_outlined), text: 'Videos'),
            Tab(icon: Icon(Icons.perm_media_outlined), text: 'All Media'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TabContentView(
            key: const PageStorageKey('images_tab'),
            subtitle: 'Pick single or multiple images using any picker shape',
            requestType: HQPickerRequestType.image,
            multiCount: 5,
            results: _results,
            onPick: _pickMedia,
            onClearResults: _clearResults,
          ),
          _TabContentView(
            key: const PageStorageKey('videos_tab'),
            subtitle: 'Pick single or multiple videos using any picker shape',
            requestType: HQPickerRequestType.video,
            multiCount: 5,
            results: _results,
            onPick: _pickMedia,
            onClearResults: _clearResults,
          ),
          _TabContentView(
            key: const PageStorageKey('all_media_tab'),
            subtitle: 'Pick images and videos combined using any picker shape',
            requestType: HQPickerRequestType.all,
            multiCount: 10,
            results: _results,
            onPick: _pickMedia,
            onClearResults: _clearResults,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab Content View
// ─────────────────────────────────────────────
class _TabContentView extends StatefulWidget {
  final String subtitle;
  final HQPickerRequestType requestType;
  final int multiCount;
  final List<HQPickerResult> results;
  final Future<void> Function({
    required HQPickerShape shape,
    required int maxCount,
    required HQPickerRequestType requestType,
  })
  onPick;
  final VoidCallback onClearResults;

  const _TabContentView({
    super.key,
    required this.subtitle,
    required this.requestType,
    required this.multiCount,
    required this.results,
    required this.onPick,
    required this.onClearResults,
  });

  @override
  State<_TabContentView> createState() => _TabContentViewState();
}

class _TabContentViewState extends State<_TabContentView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              widget.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),

        // Shape Cards List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final option = _shapes[index];
                return _ShapeCardTile(
                  option: option,
                  multiCount: widget.multiCount,
                  onPickSingle: () => widget.onPick(
                    shape: option.shape,
                    maxCount: 1,
                    requestType: widget.requestType,
                  ),
                  onPickMulti: () => widget.onPick(
                    shape: option.shape,
                    maxCount: widget.multiCount,
                    requestType: widget.requestType,
                  ),
                );
              },
              childCount: _shapes.length,
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
            ),
          ),
        ),

        // Picked Results Panel
        if (widget.results.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected Results (${widget.results.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear'),
                    onPressed: widget.onClearResults,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _ResultItemTile(result: widget.results[index]),
                childCount: widget.results.length,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Clean Material Shape Card Tile
// ─────────────────────────────────────────────
class _ShapeCardTile extends StatelessWidget {
  final _ShapeOption option;
  final int multiCount;
  final VoidCallback onPickSingle;
  final VoidCallback onPickMulti;

  const _ShapeCardTile({
    required this.option,
    required this.multiCount,
    required this.onPickSingle,
    required this.onPickMulti,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  radius: 20,
                  child: Icon(option.icon, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (option.isDirectory)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('Select Directory'),
                  onPressed: onPickSingle,
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.looks_one_outlined, size: 18),
                      label: const Text('Single'),
                      onPressed: onPickSingle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: Text('Multiple ($multiCount)'),
                      onPressed: onPickMulti,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Result Item Tile
// ─────────────────────────────────────────────
class _ResultItemTile extends StatelessWidget {
  final HQPickerResult result;
  const _ResultItemTile({required this.result});

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<File?>(
      future: result.getFile(),
      builder: (context, snapshot) {
        final file = snapshot.data ?? result.file;
        final asset = result.asset;

        final isImage =
            asset?.type == AssetType.image ||
            (file != null &&
                [
                  '.jpg',
                  '.jpeg',
                  '.png',
                  '.gif',
                  '.webp',
                  '.heic',
                ].any((ext) => file.path.toLowerCase().endsWith(ext)));

        final isVideo =
            asset?.type == AssetType.video ||
            (file != null &&
                [
                  '.mp4',
                  '.mov',
                  '.avi',
                  '.mkv',
                  '.flv',
                  '.wmv',
                ].any((ext) => file.path.toLowerCase().endsWith(ext)));

        Widget leadingWidget;
        if (asset != null) {
          leadingWidget = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: AssetEntityImage(
                asset,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(200),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _fallbackIcon(theme, isImage, isVideo),
              ),
            ),
          );
        } else if (file != null && isImage) {
          leadingWidget = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _fallbackIcon(theme, isImage, isVideo),
            ),
          );
        } else {
          leadingWidget = SizedBox(
            width: 44,
            height: 44,
            child: _fallbackIcon(theme, isImage, isVideo),
          );
        }

        String title = 'Picked File';
        if (file != null) {
          title = file.path.split('/').last;
        } else if (asset != null) {
          title = 'Asset ${asset.id}';
        }

        String subtitle = 'Loading file details...';
        if (file != null) {
          final sizeStr = file.existsSync()
              ? _formatBytes(file.lengthSync())
              : 'Unknown size';
          subtitle = '$sizeStr • ${file.path}';
        } else if (asset != null) {
          subtitle =
              '${asset.type.name.toUpperCase()} • ${asset.width}x${asset.height}';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            dense: true,
            leading: leadingWidget,
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }

  Widget _fallbackIcon(ThemeData theme, bool isImage, bool isVideo) {
    IconData iconData = Icons.insert_drive_file_outlined;
    if (isImage) {
      iconData = Icons.image_outlined;
    } else if (isVideo) {
      iconData = Icons.videocam_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: theme.colorScheme.onSurfaceVariant,
        size: 22,
      ),
    );
  }
}
