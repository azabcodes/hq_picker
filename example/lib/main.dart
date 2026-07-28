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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      ),
      home: const ExampleHomePage(),
    );
  }
}

// ─────────────────────────────────────────────
// Data model for a use-case card
// ─────────────────────────────────────────────
class _UseCase {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Future<List<HQPickerResult>> Function(BuildContext) action;

  const _UseCase({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.action,
  });
}

// ─────────────────────────────────────────────
// Home Page
// ─────────────────────────────────────────────
class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<HQPickerResult> _results = [];
  List<AssetEntity> _telegramAssets = [];
  List<FileSystemEntity> _telegramFiles = [];

  final GlobalKey<HQPickerTelegramMediaPickersState> _inlineTelegramKey =
      GlobalKey();

  // ── Tab 1: Shapes ───────────────────────────
  late final List<_UseCase> _shapeCases;

  // ── Tab 2: Types ────────────────────────────
  late final List<_UseCase> _typeCases;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _shapeCases = [
      _UseCase(
        title: 'Instagram',
        subtitle: 'Full-screen preview + grid • all media',
        icon: Icons.photo_camera,
        color: const Color(0xFFE1306C),
        action: (ctx) => HQPicker.pick(
          context: ctx,
          shape: HQPickerShape.instagram,
          maxCount: 5,
          requestType: HQPickerRequestType.all,
          config: const HQPickerConfig(
            enableCropping: true,
            compressImage: true,
          ),
        ),
      ),
      _UseCase(
        title: 'Custom (TabBar)',
        subtitle: 'Images & Videos tabs • multi-select',
        icon: Icons.grid_view,
        color: const Color(0xFF6C63FF),
        action: (ctx) => HQPicker.pick(
          context: ctx,
          shape: HQPickerShape.custom,
          maxCount: 5,
          requestType: HQPickerRequestType.all,
        ),
      ),
      _UseCase(
        title: 'Bottom Sheet',
        subtitle: 'Standard modal bottom sheet • images',
        icon: Icons.vertical_align_bottom,
        color: const Color(0xFF00BFA5),
        action: (ctx) => HQPicker.pick(
          context: ctx,
          shape: HQPickerShape.bottomSheet,
          maxCount: 5,
          requestType: HQPickerRequestType.image,
        ),
      ),
      _UseCase(
        title: 'Scaffold Bottom Sheet',
        subtitle: 'Full-height modal • videos',
        icon: Icons.expand_less,
        color: const Color(0xFFFFA000),
        action: (ctx) => HQPicker.pick(
          context: ctx,
          shape: HQPickerShape.scaffoldBottomSheet,
          maxCount: 5,
          requestType: HQPickerRequestType.video,
        ),
      ),
      _UseCase(
        title: 'Bottom Sheet Image Selector',
        subtitle: 'Album dropdown + modal • images',
        icon: Icons.photo_library,
        color: const Color(0xFF26A69A),
        action: (ctx) => HQPicker.pick(
          context: ctx,
          shape: HQPickerShape.bottomSheetImageSelector,
          maxCount: 5,
          requestType: HQPickerRequestType.image,
        ),
      ),
      _UseCase(
        title: 'Telegram',
        subtitle: 'Sliding sheet • camera + gallery + audio + files',
        icon: Icons.send,
        color: const Color(0xFF229ED9),
        action: (ctx) => HQPicker.pick(
          context: ctx,
          shape: HQPickerShape.telegram,
          maxCount: 10,
          requestType: HQPickerRequestType.all,
        ),
      ),
      _UseCase(
        title: 'Document Picker',
        subtitle: 'Native file picker • PDF / DOC / etc.',
        icon: Icons.description,
        color: const Color(0xFFEF5350),
        action: (ctx) => HQPicker.pick(
          context: ctx,
          shape: HQPickerShape.document,
          maxCount: 5,
          allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
        ),
      ),
      _UseCase(
        title: 'Directory Picker',
        subtitle: 'Native folder picker',
        icon: Icons.folder_open,
        color: const Color(0xFFFF7043),
        action: (ctx) => HQPicker.pick(
          context: ctx,
          shape: HQPickerShape.directory,
          maxCount: 1,
        ),
      ),
    ];

    _typeCases = [
      _UseCase(
        title: 'Pick Image',
        subtitle: 'Instagram shape • images only • with crop',
        icon: Icons.image,
        color: const Color(0xFFE1306C),
        action: (ctx) => HQPicker.pickImage(
          context: ctx,
          shape: HQPickerShape.instagram,
          maxCount: 5,
          config: const HQPickerConfig(enableCropping: true),
        ),
      ),
      _UseCase(
        title: 'Pick Video',
        subtitle: 'Custom shape • videos only',
        icon: Icons.videocam,
        color: const Color(0xFF6C63FF),
        action: (ctx) => HQPicker.pickVideo(
          context: ctx,
          shape: HQPickerShape.custom,
          maxCount: 3,
        ),
      ),
      _UseCase(
        title: 'Pick Images — Bottom Sheet',
        subtitle: 'bottomSheet shape • images only',
        icon: Icons.photo,
        color: const Color(0xFF00BFA5),
        action: (ctx) => HQPicker.pickImage(
          context: ctx,
          shape: HQPickerShape.bottomSheet,
          maxCount: 5,
        ),
      ),
      _UseCase(
        title: 'Pick Videos — Scaffold Sheet',
        subtitle: 'scaffoldBottomSheet • videos only',
        icon: Icons.video_library,
        color: const Color(0xFFFFA000),
        action: (ctx) => HQPicker.pickVideo(
          context: ctx,
          shape: HQPickerShape.scaffoldBottomSheet,
          maxCount: 5,
        ),
      ),
      _UseCase(
        title: 'Pick All Media — Telegram',
        subtitle: 'Telegram shape • images + videos',
        icon: Icons.perm_media,
        color: const Color(0xFF229ED9),
        action: (ctx) => HQPicker.pick(
          context: ctx,
          shape: HQPickerShape.telegram,
          maxCount: 10,
          requestType: HQPickerRequestType.all,
        ),
      ),
      _UseCase(
        title: 'Pick Document',
        subtitle: 'Native picker • any file type',
        icon: Icons.attach_file,
        color: const Color(0xFFEF5350),
        action: (ctx) => HQPicker.pickDocument(context: ctx, maxCount: 5),
      ),
      _UseCase(
        title: 'Pick Directory',
        subtitle: 'Native picker • folder/directory',
        icon: Icons.folder,
        color: const Color(0xFFFF7043),
        action: (ctx) => HQPicker.pickDirectory(context: ctx),
      ),
      _UseCase(
        title: 'Pick Images + Compress',
        subtitle: 'Instagram • images • compress 60%',
        icon: Icons.compress,
        color: const Color(0xFF26A69A),
        action: (ctx) => HQPicker.pickImage(
          context: ctx,
          shape: HQPickerShape.instagram,
          maxCount: 5,
          config: const HQPickerConfig(
            compressImage: true,
            compressQuality: 60,
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _run(_UseCase useCase) async {
    try {
      final results = await useCase.action(context);
      if (!mounted) return;
      setState(() => _results = results);
      if (results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${results.length} item(s) picked'),
            backgroundColor: const Color(0xFF1E1E2E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'HQPicker Showcase',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6C63FF),
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.style), text: 'Shapes'),
            Tab(icon: Icon(Icons.category), text: 'Types'),
            Tab(icon: Icon(Icons.telegram), text: 'Telegram'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: All Shapes ──────────────────
          _UseCaseGrid(cases: _shapeCases, onTap: _run, results: _results),

          // ── Tab 2: All Types / Methods ─────────
          _UseCaseGrid(cases: _typeCases, onTap: _run, results: _results),

          // ── Tab 3: Inline Telegram Sheet ───────
          _InlineTelegramTab(
            telegramKey: _inlineTelegramKey,
            assets: _telegramAssets,
            files: _telegramFiles,
            onPicked: (assets, files) {
              setState(() {
                _telegramAssets = assets ?? [];
                _telegramFiles = files?.cast<FileSystemEntity>() ?? [];
              });
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Grid of use-case cards + results panel
// ─────────────────────────────────────────────
class _UseCaseGrid extends StatelessWidget {
  final List<_UseCase> cases;
  final Future<void> Function(_UseCase) onTap;
  final List<HQPickerResult> results;

  const _UseCaseGrid({
    required this.cases,
    required this.onTap,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) =>
                  _CaseCard(useCase: cases[i], onTap: () => onTap(cases[i])),
              childCount: cases.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
          ),
        ),
        if (results.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white24),
                  Text(
                    '${results.length} Result(s)',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        if (results.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _ResultTile(result: results[i]),
                childCount: results.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Single use-case card
// ─────────────────────────────────────────────
class _CaseCard extends StatelessWidget {
  final _UseCase useCase;
  final VoidCallback onTap;

  const _CaseCard({required this.useCase, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              useCase.color.withValues(alpha: 0.85),
              useCase.color.withValues(alpha: 0.45),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: useCase.color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(useCase.icon, color: Colors.white, size: 28),
            const Spacer(),
            Text(
              useCase.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              useCase.subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 10.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Single result row
// ─────────────────────────────────────────────
class _ResultTile extends StatelessWidget {
  final HQPickerResult result;
  const _ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final file = result.file;
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
            ].any((ext) => file.path.toLowerCase().endsWith(ext)));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 50,
            height: 50,
            child: file != null && isImage
                ? Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _typeIcon(asset),
                  )
                : _typeIcon(asset),
          ),
        ),
        title: Text(
          file != null ? file.path.split('/').last : 'Asset ${asset?.id ?? ''}',
          style: const TextStyle(color: Colors.white, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          asset != null ? 'Type: ${asset.type.name}' : file?.path ?? '',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _typeIcon(AssetEntity? asset) {
    IconData icon;
    Color color;
    switch (asset?.type) {
      case AssetType.video:
        icon = Icons.videocam;
        color = const Color(0xFF6C63FF);
        break;
      case AssetType.audio:
        icon = Icons.audiotrack;
        color = const Color(0xFFFFA000);
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.white38;
    }
    return Container(
      color: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 3 — Inline Telegram sheet
// ─────────────────────────────────────────────
class _InlineTelegramTab extends StatelessWidget {
  final GlobalKey<HQPickerTelegramMediaPickersState> telegramKey;
  final List<AssetEntity> assets;
  final List<FileSystemEntity> files;
  final void Function(List<AssetEntity>?, List<dynamic>?) onPicked;

  const _InlineTelegramTab({
    required this.telegramKey,
    required this.assets,
    required this.files,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF229ED9), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.telegram, color: Colors.white, size: 36),
                const SizedBox(height: 10),
                const Text(
                  'Inline Telegram Picker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sliding sheet embedded in the page.\nSupports camera, gallery, audio & files.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF229ED9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Toggle Telegram Sheet'),
                  onPressed: () =>
                      telegramKey.currentState?.toggleSheet(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Inline widget
          HQPickerTelegramMediaPickers(
            key: telegramKey,
            requestType: HQPickerRequestType.all,
            maxCountPickMedia: 10,
            maxCountPickFiles: 10,
            primeryColor: const Color(0xFF229ED9),
            isRealCameraView: false,
            onMediaPicked: onPicked,
          ),

          // Picked assets
          if (assets.isNotEmpty) ...[
            const Divider(color: Colors.white24),
            Text(
              '${assets.length} Media Asset(s)',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...assets.map(
              (a) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(
                    a.type == AssetType.video ? Icons.videocam : Icons.image,
                    color: const Color(0xFF229ED9),
                  ),
                  title: Text(
                    'Asset: ${a.id}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  subtitle: Text(
                    'Type: ${a.type.name}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],

          // Picked files
          if (files.isNotEmpty) ...[
            const Divider(color: Colors.white24),
            Text(
              '${files.length} File(s)',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...files.map(
              (f) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.insert_drive_file,
                    color: Color(0xFFFFA000),
                  ),
                  title: Text(
                    f.path.split('/').last,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    f.path,
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
