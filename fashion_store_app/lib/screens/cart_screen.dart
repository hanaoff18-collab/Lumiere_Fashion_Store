import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';
import 'checkout_screen.dart';
import 'product_list_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: fashionAppBar(
        context,
        'Your bag',
        actions: [
          Consumer<CartProvider>(
            builder: (ctx, cart, _) {
              if (cart.items.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  cart.clearCart();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bag cleared', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                      backgroundColor: AppColors.textPrimary,
                    ),
                  );
                },
                child: Text(
                  'Clear',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: AppColors.headerGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Icon(Icons.shopping_bag_outlined, size: 56, color: Colors.white.withOpacity(0.95)),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Your bag is waiting',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add pieces you love — we will hold them here.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductListScreen()),
                        );
                      },
                      icon: const Icon(Icons.explore_rounded),
                      label: const Text('Browse collection'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, index) {
                    final item = cart.items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                            child: Image.network(
                              item.imageUrl,
                              width: 108,
                              height: 108,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 108,
                                height: 108,
                                color: AppColors.surfaceContainer,
                                child: const Icon(Icons.image_not_supported_outlined),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _qtyControl(
                                        context,
                                        cart,
                                        item.id,
                                        item.quantity,
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () => cart.removeFromCart(item.id),
                                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '\$${cart.totalAmount.toStringAsFixed(2)}',
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.local_offer_outlined,
                                  color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Coupons and promos can be applied in checkout',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                  height: 1.35,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'Proceed to checkout',
                            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _qtyControl(BuildContext context, CartProvider cart, String id, int qty) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove_rounded, size: 20),
            onPressed: () => cart.updateQuantity(id, qty - 1),
            color: AppColors.primary,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add_rounded, size: 20),
            onPressed: () => cart.updateQuantity(id, qty + 1),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
