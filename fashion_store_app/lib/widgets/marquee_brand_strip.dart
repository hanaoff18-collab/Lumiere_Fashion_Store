import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import '../theme/app_theme.dart';

/// Horizontally scrolling brand logos in a seamless loop (marquee).
class MarqueeBrandStrip extends StatefulWidget {
  const MarqueeBrandStrip({
    super.key,
    required this.assetPaths,
    this.logoSize = 52,
    this.gap = 12,
  });

  final List<String> assetPaths;
  final double logoSize;
  final double gap;

  @override
  State<MarqueeBrandStrip> createState() => _MarqueeBrandStripState();
}

class _MarqueeBrandStripState extends State<MarqueeBrandStrip>
    with SingleTickerProviderStateMixin {
  late final ScrollController _controller;
  Ticker? _ticker;
  double _loopWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _measureLoop();
    _ticker = createTicker(_onTick)..start();
  }

  void _measureLoop() {
    if (!mounted) return;
    final n = widget.assetPaths.length;
    if (n == 0) return;
    _loopWidth = n * (widget.logoSize + widget.gap);
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !_controller.hasClients || _loopWidth <= 0) return;
    final next = _controller.offset + 0.45;
    if (next >= _loopWidth) {
      _controller.jumpTo(next - _loopWidth);
    } else {
      _controller.jumpTo(next);
    }
  }

  @override
  void didUpdateWidget(covariant MarqueeBrandStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPaths.length != widget.assetPaths.length ||
        oldWidget.logoSize != widget.logoSize ||
        oldWidget.gap != widget.gap) {
      _measureLoop();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _logoCircle(String path) {
    return Container(
      width: widget.logoSize,
      height: widget.logoSize,
      margin: EdgeInsets.only(right: widget.gap),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => Icon(
              Icons.storefront_outlined,
              size: 22,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assetPaths.isEmpty) return const SizedBox.shrink();

    final paths = widget.assetPaths;
    // Two copies for infinite scroll illusion
    final rowChildren = <Widget>[
      ...paths.map(_logoCircle),
      ...paths.map(_logoCircle),
    ];

    return ClipRect(
      child: SizedBox(
        height: widget.logoSize,
        child: ListView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          children: rowChildren,
        ),
      ),
    );
  }
}
