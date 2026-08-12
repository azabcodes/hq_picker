import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../config/hq_picker_config.dart';

/// A modern, high-quality full-screen media preview dialog for images and videos.
class HQMediaPreviewDialog extends StatefulWidget {
  final AssetEntity asset;
  final HQPickerConfig config;

  const HQMediaPreviewDialog({
    super.key,
    required this.asset,
    required this.config,
  });

  /// Displays the preview dialog.
  /// If [HQPickerConfig.previewDialogBuilder] is provided, it delegates rendering
  /// to the custom builder.
  static Future<void> show(
    BuildContext context,
    AssetEntity asset,
    HQPickerConfig config,
  ) {
    if (config.previewDialogBuilder != null) {
      return showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (ctx) => config.previewDialogBuilder!(ctx, asset),
      );
    }

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return HQMediaPreviewDialog(
          asset: asset,
          config: config,
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<HQMediaPreviewDialog> createState() => _HQMediaPreviewDialogState();
}

class _HQMediaPreviewDialogState extends State<HQMediaPreviewDialog> {
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      const double zoomScale = 2.5;
      final double tx = -position.dx * 1.5;
      final double ty = -position.dy * 1.5;
      _transformationController.value = Matrix4(
        zoomScale,
        0,
        0,
        0,
        0,
        zoomScale,
        0,
        0,
        0,
        0,
        1,
        0,
        tx,
        ty,
        0,
        1,
      );
    }
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.asset.type == AssetType.video;
    final mediaTypeString = isVideo ? 'VIDEO' : 'IMAGE';

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── Background Tap to Dismiss ──────────────────────────────
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),

            // ── Interactive Media Viewer ───────────────────────────────
            Center(
              child: GestureDetector(
                onDoubleTapDown: _handleDoubleTapDown,
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AssetEntityImage(
                        widget.asset,
                        isOriginal: true,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: widget.config.loadingWidget ??
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      widget.config.theme.primaryColor,
                                    ),
                                  ),
                                ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.broken_image_rounded, size: 48, color: Colors.white54),
                            SizedBox(height: 8),
                            Text(
                              'Unable to load preview',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                      // Video Indicator Overlay
                      if (isVideo)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Floating Top Glass Header Bar ──────────────────────────
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Media Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.config.theme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVideo ? Icons.videocam_rounded : Icons.image_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                mediaTypeString,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Media Details Chips
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (widget.asset.width > 0 && widget.asset.height > 0) ...[
                                  Text(
                                    '${widget.asset.width} × ${widget.asset.height}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                if (isVideo) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.timer_outlined,
                                          size: 12,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDuration(widget.asset.duration),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Close Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
