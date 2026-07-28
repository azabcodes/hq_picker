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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
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
          enableCropping: false,
          compressImage: false,
          // ── Theming example ──────────────────────────────
          theme: const HQPickerTheme(
            backgroundColor: Color(0xFF1E1E2E),
            appbarColor: Color(0xFF1E1E2E),
            backgroundDropDownColor: Color(0xFF2A2D3E),
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
        ),
      );

      if (!mounted) return;
      setState(() => _results = results);

      if (results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${results.length} item(s) selected'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to pick: $e'),
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
  }) onPick;
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
                (context, index) => _ResultItemTile(
                  result: widget.results[index],
                ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = result.file;
    final asset = result.asset;

    final isImage = asset?.type == AssetType.image ||
        (file != null &&
            ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic']
                .any((ext) => file.path.toLowerCase().endsWith(ext)));

    final isVideo = asset?.type == AssetType.video ||
        (file != null &&
            ['.mp4', '.mov', '.avi', '.mkv', '.flv', '.wmv']
                .any((ext) => file.path.toLowerCase().endsWith(ext)));

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
            errorBuilder: (_, __, ___) => _fallbackIcon(theme, isImage, isVideo),
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
          errorBuilder: (_, __, ___) => _fallbackIcon(theme, isImage, isVideo),
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

    String subtitle = '';
    if (asset != null) {
      subtitle = '${asset.type.name.toUpperCase()} • ${asset.width}x${asset.height}';
    } else if (file != null) {
      subtitle = file.path;
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
