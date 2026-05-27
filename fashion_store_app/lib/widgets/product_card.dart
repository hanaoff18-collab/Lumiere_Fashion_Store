import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../screens/product_detail_screen.dart';
import '../theme/app_theme.dart';

enum ProductCardLayout { compact, grid, list }

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductCardLayout layout;

  const ProductCard({
    super.key,
    required this.product,
    this.layout = ProductCardLayout.grid,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: switch (layout) {
        ProductCardLayout.compact => _compactCard(context),
        ProductCardLayout.grid => _gridCard(context),
        ProductCardLayout.list => _listCard(context),
      },
    );
  }

  Widget _gridCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceContainer,
                        child: const Icon(Icons.image_not_supported_outlined, size: 40, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                if (product.isFeatured)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.82)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'HOT',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: _addButton(context, small: true),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _wishButton(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.25),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    if (product.isFeatured) ...[
                      const SizedBox(width: 6),
                      Text(
                        '\$${(product.price * 1.2).toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  product.imageUrl,
                  height: 156,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 156,
                    color: AppColors.surfaceContainer,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              if (product.isFeatured)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.85)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'HOT',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: _wishButton(context),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    const Spacer(),
                    _addButton(context, small: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            child: Image.network(
              product.imageUrl,
              width: 112,
              height: 112,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 112,
                height: 112,
                color: AppColors.surfaceContainer,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade600),
                      Text(
                        ' 4.8',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      _addButton(context, small: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addButton(BuildContext context, {required bool small}) {
    return Material(
      color: AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          context.read<CartProvider>().addToCart(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to bag', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(small ? 8 : 10),
          child: Icon(Icons.add_shopping_cart_rounded, size: small ? 18 : 20, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _wishButton(BuildContext context) {
    final wish = context.watch<WishlistProvider>();
    final isFav = wish.isFavorite(product.id);
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => wish.toggle(product.id),
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFav ? Colors.red : AppColors.primary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
