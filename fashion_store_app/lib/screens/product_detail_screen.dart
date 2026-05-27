import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';
import '../services/catalog_repository.dart';
import '../widgets/product_card.dart';
import '../theme/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedSize = 0;
  int _quantity = 1;
  final CatalogRepository _catalog = CatalogRepository();

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        clipBehavior: Clip.none,
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            stretch: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            backgroundColor: AppColors.primaryDark,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    p.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainer),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                        stops: const [0, 0.32, 1],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1E2130).withValues(alpha: 0.22),
                            Colors.transparent,
                            const Color(0xFF3D3548).withValues(alpha: 0.18),
                          ],
                          stops: const [0, 0.45, 1],
                        ),
                      ),
                    ),
                  ),
                  if (p.isFeatured)
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 52,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.85)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          '20% OFF',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.outline.withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    height: 1.16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${p.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (p.isFeatured)
                                    Text(
                                      '\$${(p.price * 1.2).toStringAsFixed(2)}',
                                      style: GoogleFonts.plusJakartaSans(
                                        decoration: TextDecoration.lineThrough,
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _pill(Icons.verified_rounded, 'Original'),
                              _pill(Icons.local_shipping_rounded, 'Fast delivery'),
                              _pill(Icons.replay_rounded, '7-day return'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 390;
                        return Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                                color: Colors.amber.shade600,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '4.8  ·  128 reviews',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (!compact)
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.rate_review_outlined, size: 18),
                                label: const Text('Write review'),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Description',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (p.sizes.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Size',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: p.sizes.asMap().entries.map((e) {
                          final i = e.key;
                          final size = e.value;
                          final sel = _selectedSize == i;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() => _selectedSize = i),
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                constraints: const BoxConstraints(minHeight: 48),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: sel
                                      ? LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primary.withValues(alpha: 0.88),
                                          ],
                                        )
                                      : null,
                                  color: sel ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: sel
                                        ? Colors.transparent
                                        : AppColors.outline.withValues(alpha: 0.85),
                                    width: 1.5,
                                  ),
                                  boxShadow: sel
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.22),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.04),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                ),
                                child: Center(
                                  widthFactor: 1,
                                  child: Text(
                                    size,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: sel ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (p.colors.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Text(
                        'Colors',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: p.colors
                            .map((c) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.outline.withValues(alpha: 0.6)),
                                  ),
                                  child: Text(
                                    c,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Quantity',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.7)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                            icon: const Icon(Icons.remove_rounded),
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '$_quantity',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _quantity++),
                            icon: const Icon(Icons.add_rounded),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.45)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined,
                              color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Secure payment · Genuine products · Easy exchange',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    StreamBuilder<List<Product>>(
                      stream: _catalog.watchProducts(),
                      builder: (context, snapshot) {
                        final related = (snapshot.data ?? [])
                            .where((x) =>
                                x.id != p.id && x.category == p.category)
                            .take(8)
                            .toList();
                        if (related.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You may also like',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 276,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: related.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: SizedBox(
                                      width: 165,
                                      child: ProductCard(
                                        product: related[index],
                                        layout: ProductCardLayout.compact,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Material(
          elevation: 0,
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.outline.withValues(alpha: 0.55)),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 32,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 54,
                            height: 54,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.outline.withValues(alpha: 0.9),
                              ),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            for (var i = 0; i < _quantity; i++) {
                              context.read<CartProvider>().addToCart(p);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added $_quantity item(s) to your bag',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(0, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Add to bag · \$${(p.price * _quantity).toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      final directItem = CartItem(
                        id: 'buy-now-${DateTime.now().millisecondsSinceEpoch}',
                        productId: p.id,
                        name: p.name,
                        price: p.price,
                        quantity: _quantity,
                        imageUrl: p.imageUrl,
                        selectedSize: p.sizes.isNotEmpty
                            ? p.sizes[_selectedSize]
                            : null,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            buyNowItems: [directItem],
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: BorderSide(
                        color: AppColors.outline.withValues(alpha: 0.95),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Buy now',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
