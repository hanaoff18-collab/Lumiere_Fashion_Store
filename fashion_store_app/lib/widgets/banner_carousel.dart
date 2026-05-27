import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/promo_banner.dart';
import '../theme/app_theme.dart';

class BannerCarousel extends StatefulWidget {
  final bool autoPlay;
  final Duration autoPlayInterval;
  /// From Firestore `banners` only (empty = hide carousel).
  final List<PromoBanner> banners;

  const BannerCarousel({
    super.key,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.banners = const [],
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentPage = 0;
  late PageController _pageController;
  Timer? _autoPlayTimer;

  int get _count => widget.banners.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
    if (widget.autoPlay) {
      _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) => _autoScrollTick());
    }
  }

  void _autoScrollTick() {
    if (!mounted || !_pageController.hasClients) return;
    if (_count == 0) return;
    final next = (_currentPage + 1) % _count;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 188,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              padEnds: true,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _count,
              itemBuilder: (ctx, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double pageDelta = 0;
                    // Must check hasClients before .position — otherwise Flutter throws.
                    if (_pageController.hasClients && _pageController.position.haveDimensions) {
                      pageDelta = index - (_pageController.page ?? _pageController.initialPage.toDouble());
                    }
                    final angle = (pageDelta * -0.14).clamp(-0.35, 0.35);
                    final scale = 1 - (pageDelta.abs() * 0.06).clamp(0.0, 0.12);
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0011)
                        ..rotateY(angle),
                      child: Transform.scale(scale: scale, child: child),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: _RemoteBannerSlide(banner: widget.banners[index]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _count,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 28 : 7,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _currentPage == index ? AppColors.accent : AppColors.outline.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoteBannerSlide extends StatelessWidget {
  const _RemoteBannerSlide({required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            banner.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.surfaceContainer),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  banner.title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  banner.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'SPONSORED',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
