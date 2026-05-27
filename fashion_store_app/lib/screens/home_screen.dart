import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../models/promo_banner.dart';
import '../services/catalog_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/category_card.dart';
import '../widgets/marquee_brand_strip.dart';
import '../widgets/banner_carousel.dart';
import '../utils/category_assets.dart';
import '../widgets/motion_3d.dart';
import '../widgets/perspective_card.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'category_screen.dart';
import 'offers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const CategoryScreen(),
    const CartScreen(),
    OffersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
                      .animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: NavigationBar(
                  height: 68,
                  selectedIndex: _currentIndex,
                  indicatorColor: AppColors.accent.withValues(alpha: 0.22),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.home_rounded,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.88)),
                      selectedIcon: const Icon(Icons.home_rounded,
                          color: AppColors.primary),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_rounded,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.88)),
                      selectedIcon: const Icon(Icons.grid_view_rounded,
                          color: AppColors.primary),
                      label: 'Shop',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: cart.itemCount > 0,
                        backgroundColor: AppColors.accent,
                        label: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        child: Icon(Icons.shopping_bag_outlined,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.88)),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: cart.itemCount > 0,
                        backgroundColor: AppColors.accent,
                        label: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        child: const Icon(Icons.shopping_bag_rounded,
                            color: AppColors.primary),
                      ),
                      label: 'Cart',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.local_offer_outlined,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.88)),
                      selectedIcon: const Icon(Icons.local_offer_rounded,
                          color: AppColors.primary),
                      label: 'Deals',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.88)),
                      selectedIcon: const Icon(Icons.person_rounded,
                          color: AppColors.primary),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with TickerProviderStateMixin {
  final CatalogRepository _catalog = CatalogRepository();
  late AnimationController _motion;
  late AnimationController _card3d;

  @override
  void initState() {
    super.initState();
    _motion =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);
    _card3d =
        AnimationController(vsync: this, duration: const Duration(seconds: 9))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _motion.dispose();
    _card3d.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: _catalog.watchProducts(),
      builder: (context, productSnapshot) {
        final waiting = productSnapshot.connectionState ==
                ConnectionState.waiting &&
            !productSnapshot.hasData;
        if (waiting) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(child: _buildHeroHeader(context)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      children: List.generate(
                        4,
                        (_) => Container(
                          height: 98,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (productSnapshot.hasError) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: _buildHeroHeader(context)),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Could not load catalog.\n${productSnapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        final products = productSnapshot.data ?? [];
        final featuredProducts =
            products.where((p) => p.isFeatured).toList();
        final newArrivals =
            products.where((p) => !p.isFeatured).take(6).toList();
        final displayCategories = products
            .map((p) => p.category.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .map((name) => {'name': name, 'icon': '🛍️'})
            .toList();

        final slivers = <Widget>[
          SliverToBoxAdapter(child: _buildHeroHeader(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 6)),
          SliverToBoxAdapter(
            child: StreamBuilder<List<PromoBanner>>(
              stream: _catalog.watchBanners(),
              builder: (context, bannerSnapshot) {
                return BannerCarousel(
                  banners: bannerSnapshot.data ?? <PromoBanner>[],
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: _trustStrip(context)),
        ];

        if (products.isEmpty) {
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'No products yet. Add documents in Firestore collection '
                  '`products` and images in Storage under the paths in `imagePath`.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }

        if (displayCategories.isNotEmpty) {
          slivers.addAll([
            SliverToBoxAdapter(
              child: _sectionTitle(context, 'Shop by category', 'Explore', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CategoryScreen()));
              }),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 122,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayCategories.length,
                  itemBuilder: (ctx, index) {
                    final catName = displayCategories[index]['name']!;
                    return CategoryCard(
                      name: catName,
                      icon: displayCategories[index]['icon']!,
                      index: index,
                      heroImageAsset: categoryHeroAsset(catName),
                    );
                  },
                ),
              ),
            ),
          ]);
        }

        if (featuredProducts.isNotEmpty) {
          slivers.addAll([
            SliverToBoxAdapter(
              child: _sectionTitle(
                  context, 'Featured picks', 'View all', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProductListScreen()));
              }),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 296,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: featuredProducts.length,
                  itemBuilder: (ctx, index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.96, end: 1),
                      duration: Duration(milliseconds: 400 + index * 60),
                      curve: Curves.easeOutCubic,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: SizedBox(
                          width: 172,
                          child: Float3D(
                            animation: _card3d,
                            phase: index * 0.14,
                            xAmp: 0.045,
                            yAmp: 0.035,
                            child: ProductCard(
                              product: featuredProducts[index],
                              layout: ProductCardLayout.compact,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ]);
        }

        if (newArrivals.isNotEmpty) {
          slivers.addAll([
            SliverToBoxAdapter(
              child: _sectionTitle(context, 'New in store', 'See all', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProductListScreen()));
              }),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 296,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: newArrivals.length,
                  itemBuilder: (ctx, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: SizedBox(
                        width: 172,
                        child: Float3D(
                          animation: _card3d,
                          phase: index * 0.11 + 0.4,
                          xAmp: 0.04,
                          yAmp: 0.03,
                          child: ProductCard(
                            product: newArrivals[index],
                            layout: ProductCardLayout.compact,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ]);
        }

        slivers.addAll([
          SliverToBoxAdapter(child: _editorialBlock(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(child: _partnerStrip(context)),
          SliverToBoxAdapter(child: _promoBanner(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]);

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: slivers,
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -28,
            top: 48,
            child: IgnorePointer(
              child: Float3D(
                animation: _motion,
                phase: 0,
                xAmp: 0.1,
                yAmp: 0.07,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -36,
            bottom: 100,
            child: IgnorePointer(
              child: Float3D(
                animation: _card3d,
                phase: 0.55,
                xAmp: 0.08,
                yAmp: 0.06,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                size: 15,
                                color:
                                    AppColors.accent.withValues(alpha: 0.95)),
                            const SizedBox(width: 6),
                            Text(
                              'Lumière · SS26',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(Icons.notifications_none_rounded,
                                color: Colors.white.withValues(alpha: 0.95),
                                size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AnimatedBuilder(
                    animation: _motion,
                    builder: (context, child) {
                      final t = _motion.value;
                      final y = math.sin(t * math.pi * 2) * 4;
                      return Transform.translate(
                        offset: Offset(0, y),
                        child: child,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Curated for you',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quiet luxury.\nBold silhouette.',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            height: 1.12,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up_rounded,
                            size: 16,
                            color: AppColors.accent.withValues(alpha: 0.95)),
                        const SizedBox(width: 8),
                        Text(
                          'Trending now · Updated daily',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.94),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Float3D(
                    animation: _card3d,
                    phase: 0.12,
                    xAmp: 0.035,
                    yAmp: 0.028,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProductListScreen()));
                        },
                        decoration: InputDecoration(
                          hintText: 'Search collections, fabrics, fits…',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.72),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.primary, size: 24),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(Icons.tune_rounded,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.55)),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trustStrip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Float3D(
        animation: _motion,
        phase: 0.42,
        xAmp: 0.018,
        yAmp: 0.014,
        child: GlassPanel(
          borderRadius: 22,
          blur: 16,
          opacity: 0.78,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                _trustChip(Icons.verified_user_outlined, 'Secure checkout'),
                _trustDivider(),
                _trustChip(Icons.local_shipping_outlined, 'Free returns'),
                _trustDivider(),
                _trustChip(Icons.star_rounded, '4.9 store rating'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _trustDivider() {
    return Container(
        width: 1, height: 28, color: AppColors.outline.withValues(alpha: 0.55));
  }

  Widget _trustChip(IconData icon, String label) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editorialBlock(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Float3D(
        animation: _card3d,
        phase: 0.28,
        xAmp: 0.025,
        yAmp: 0.02,
        child: PerspectiveCard(
          tiltY: 0.04,
          depth: 0.0014,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.88),
                  const Color(0xFF3D3548),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THE EDIT',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.accent.withValues(alpha: 0.95),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Layered neutrals & sculptural tailoring — how our stylists build a week of outfits.',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.94),
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProductListScreen()));
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Read stories',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.28)),
                  ),
                  child: Icon(Icons.menu_book_rounded,
                      color: AppColors.accent.withValues(alpha: 0.95),
                      size: 34),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const List<String> _featuredBrandAssets = [
    'assets/brands/brand_1.png',
    'assets/brands/brand_2.png',
    'assets/brands/brand_3.png',
    'assets/brands/brand_4.png',
    'assets/brands/brand_5.png',
    'assets/brands/brand_6.png',
    'assets/brands/brand_7.png',
  ];

  Widget _partnerStrip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured houses',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: AppColors.outline.withValues(alpha: 0.45)),
            ),
            child: ExcludeSemantics(
              child: MarqueeBrandStrip(assetPaths: _featuredBrandAssets),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
      BuildContext context, String title, String action, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.35,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onTap,
            child: Row(
              children: [
                Text(
                  action,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded,
                    size: 18, color: AppColors.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Float3D(
        animation: _card3d,
        phase: 0.55,
        xAmp: 0.035,
        yAmp: 0.028,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: AppColors.offerGradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.38),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'MEMBER ACCESS',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '20% off accessories',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Eligible styles — stacks with free shipping over \$90',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProductListScreen(
                                  category: 'Accessories')),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Shop now',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Icon(Icons.card_giftcard_rounded,
                    size: 48, color: Colors.white.withValues(alpha: 0.95)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
