import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_success_screen.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, this.buyNowItems});

  final List<CartItem>? buyNowItems;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _voucherController = TextEditingController();

  String _paymentMethod = 'Credit Card';
  bool _saveInfo = false;
  String? _voucherCode;
  double _discountAmount = 0;
  bool _placingOrder = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final checkoutItems = widget.buyNowItems ?? cart.items;
    final subtotal = checkoutItems.fold<double>(
      0,
      (acc, i) => acc + (i.price * i.quantity),
    );
    final shippingCost = subtotal > 50 ? 0.0 : 5.0;
    final totalBeforeDiscount = subtotal + shippingCost;
    final total = (totalBeforeDiscount - _discountAmount).clamp(0, double.infinity);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: fashionAppBar(context, 'Checkout'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _card(
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      '${checkoutItems.length} items',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionLabel('Ship to'),
              _card(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline_rounded)),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Street address', prefixIcon: Icon(Icons.location_on_outlined)),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(labelText: 'City'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _zipController,
                            decoration: const InputDecoration(labelText: 'ZIP'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('Payment'),
              _card(
                child: Column(
                  children: [
                    _payTile('Credit / debit card', 'Credit Card', Icons.credit_card_rounded),
                    Divider(height: 1, color: AppColors.outline.withOpacity(0.5)),
                    _payTile('PayPal', 'PayPal', Icons.account_balance_wallet_outlined),
                    Divider(height: 1, color: AppColors.outline.withOpacity(0.5)),
                    _payTile('Cash on delivery', 'Cash', Icons.payments_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Save for next time', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                value: _saveInfo,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _saveInfo = v ?? false),
              ),
              const SizedBox(height: 16),
              _sectionLabel('Order summary'),
              _card(
                child: Column(
                  children: [
                    _sumRow('Subtotal (${checkoutItems.length} items)',
                        '\$${subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 10),
                    _sumRow('Shipping', shippingCost == 0 ? 'Free' : '\$${shippingCost.toStringAsFixed(2)}'),
                    const SizedBox(height: 10),
                    _sumRow('Tax', '\$0.00'),
                    if (_discountAmount > 0) ...[
                      const SizedBox(height: 10),
                      _sumRow('Voucher ($_voucherCode)', '-\$${_discountAmount.toStringAsFixed(2)}'),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: AppColors.outline.withOpacity(0.6)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _voucherController,
                        decoration: const InputDecoration(
                          labelText: 'Voucher code',
                          prefixIcon: Icon(Icons.confirmation_number_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _applyVoucher,
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: FilledButton(
            onPressed: _placingOrder
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _placingOrder = true);
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) throw Exception('Please sign in again.');
                      final orderId =
                          'ORD${DateTime.now().millisecondsSinceEpoch % 100000}';
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('orders')
                          .add({
                        'orderId': orderId,
                        'status': 'Placed',
                        'paymentMethod': _paymentMethod,
                        'saveInfo': _saveInfo,
                        'voucherCode': _voucherCode,
                        'discountAmount': _discountAmount,
                        'subtotal': subtotal,
                        'shipping': shippingCost,
                        'total': total,
                        'items': checkoutItems
                            .map((i) => {
                                  'productId': i.productId,
                                  'name': i.name,
                                  'price': i.price,
                                  'quantity': i.quantity,
                                  'imageUrl': i.imageUrl,
                                  'selectedSize': i.selectedSize,
                                  'selectedColor': i.selectedColor,
                                })
                            .toList(),
                        'shippingDetails': {
                          'name': _nameController.text.trim(),
                          'email': _emailController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'address': _addressController.text.trim(),
                          'city': _cityController.text.trim(),
                          'zip': _zipController.text.trim(),
                        },
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      if (!mounted) return;
                      if (widget.buyNowItems == null) {
                        context.read<CartProvider>().clearCart();
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => OrderSuccessScreen(orderId: orderId)),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order failed: $e')),
                      );
                    } finally {
                      if (mounted) setState(() => _placingOrder = false);
                    }
                  },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _placingOrder
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Place order · \$${total.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        t,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }

  Widget _sumRow(String a, String b) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14)),
        Text(b, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }

  Widget _payTile(String title, String value, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _paymentMethod,
      onChanged: (v) => setState(() => _paymentMethod = v!),
      activeColor: AppColors.primary,
      title: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600))),
        ],
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _applyVoucher() {
    final code = _voucherController.text.trim().toUpperCase();
    final map = <String, double>{
      'SAVE10': 0.10,
      'NEW20': 0.20,
      'FREESHIP': 0.05,
    };
    final pct = map[code];
    if (pct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid voucher code')),
      );
      return;
    }
    final cart = context.read<CartProvider>();
    final checkoutItems = widget.buyNowItems ?? cart.items;
    final subtotal = checkoutItems.fold<double>(
      0,
      (acc, i) => acc + (i.price * i.quantity),
    );
    final shipping = subtotal > 50 ? 0.0 : 5.0;
    final base = subtotal + shipping;
    setState(() {
      _voucherCode = code;
      _discountAmount = base * pct;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Voucher applied: $code')),
    );
  }
}
