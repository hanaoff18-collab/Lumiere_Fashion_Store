import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../services/catalog_repository.dart';
import '../theme/app_theme.dart';
import '../utils/category_assets.dart';
import '../widgets/gradient_app_bar.dart';
import 'product_list_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  static final CatalogRepository _catalog = CatalogRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: fashionAppBar(context, 'Categories'),
      body: StreamBuilder<List<Product>>(
        stream: _catalog.watchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _promoSkeleton()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => _categoryTileSkeleton(),
                      childCount: 4,
                    ),
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load categories.',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          final products = snapshot.data ?? [];
          final uniqueCategories = products
              .map((p) => p.category.trim())
              .where((e) => e.isNotEmpty)
              .toSet()
              .toList();
          if (uniqueCategories.isEmpty) {
            return Center(
              child: Text(
                'No categories yet. Add products in Firestore.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _promoBanner(context, products),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Browse departments',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${uniqueCategories.length} shops',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) {
                      final name = uniqueCategories[index];
                      final productCount =
                          products.where((p) => p.category == name).length;
                      final asset = categoryHeroAsset(name);
                      return _CategoryHeroTile(
                        name: name,
                        productCount: productCount,
                        imageAsset: asset,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductListScreen(category: name),
                            ),
                          );
                        },
                      );
                    },
                    childCount: uniqueCategories.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _promoSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 168,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _categoryTileSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  /// Resolves a category string that exists in the catalog (e.g. "sports" vs "Sports").
  static String? _categoryMatching(
      List<Product> products, bool Function(String lower) test) {
    final seen = <String>{};
    for (final p in products) {
      final c = p.category.trim();
      if (c.isEmpty || seen.contains(c)) continue;
      seen.add(c);
      if (test(c.toLowerCase())) return c;
    }
    return null;
  }

  Widget _promoBanner(BuildContext context, List<Product> products) {
    final sportsName = _categoryMatching(
      products,
      (low) => low.contains('sport'),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => sportsName != null
                    ? ProductListScreen(category: sportsName)
                    : const ProductListScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            height: 172,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/categories/cat_sports.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1A1D24),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.72),
                          Colors.black.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'SPONSORED',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Performance week',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Train harder · Street-ready gear · Member prices',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.88),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            FilledButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => sportsName != null
                                        ? ProductListScreen(category: sportsName)
                                        : const ProductListScreen(),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.textPrimary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Shop sports',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ProductListScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'View all',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryHeroTile extends StatelessWidget {
  const _CategoryHeroTile({
    required this.name,
    required this.productCount,
    required this.imageAsset,
    required this.onTap,
  });

  final String name;
  final int productCount;
  final String? imageAsset;
  final VoidCallback onTap;

  static const List<List<Color>> _fallback = [
    [Color(0xFF2C3E50), Color(0xFF4A6741)],
    [Color(0xFF4A3F6B), Color(0xFF7B6BA8)],
    [Color(0xFF5C4033), Color(0xFF8B6914)],
    [Color(0xFF1B2838), Color(0xFF34495E)],
  ];

  @override
  Widget build(BuildContext context) {
    final hash = name.hashCode.abs();
    final grad = _fallback[hash % _fallback.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageAsset != null)
                  Image.asset(
                    imageAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _gradientOnly(grad),
                  )
                else
                  _gradientOnly(grad),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$productCount styles · Tap to shop',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gradientOnly(List<Color> grad) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: grad,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
