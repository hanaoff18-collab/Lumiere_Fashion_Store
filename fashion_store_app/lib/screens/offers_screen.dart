import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../services/catalog_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/product_card.dart';

class OffersScreen extends StatelessWidget {
  OffersScreen({super.key});

  final CatalogRepository _catalog = CatalogRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: fashionAppBar(context, 'Flash deals'),
      body: StreamBuilder<List<Product>>(
        stream: _catalog.watchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final all = snapshot.data ?? [];
          final offers = all.where((p) => p.isFeatured).toList();
          if (offers.isEmpty) {
            return Center(
              child: Text(
                'No featured deals right now.',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: offers[index],
                layout: ProductCardLayout.list,
              );
            },
          );
        },
      ),
    );
  }
}
