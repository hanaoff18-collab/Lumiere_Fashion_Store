import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/wishlist_provider.dart';
import '../services/catalog_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  WishlistScreen({super.key});

  final CatalogRepository _catalog = CatalogRepository();

  @override
  Widget build(BuildContext context) {
    final favIds = context.watch<WishlistProvider>().favoriteIds;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: fashionAppBar(context, 'Wishlist'),
      body: StreamBuilder<List<Product>>(
        stream: _catalog.watchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return GridView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }
          final all = snapshot.data ?? [];
          final items = all.where((p) => favIds.contains(p.id)).toList();
          if (items.isEmpty) {
            return Center(
              child: Text(
                favIds.isEmpty
                    ? 'No favorites yet'
                    : 'Favorites will appear after catalog loads.',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: items[index],
                layout: ProductCardLayout.grid,
              );
            },
          );
        },
      ),
    );
  }
}
