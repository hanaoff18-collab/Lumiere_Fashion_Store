import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: fashionAppBar(context, 'My orders'),
      body: user == null
          ? Center(
              child: Text(
                'Sign in to view orders',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No orders yet',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    return _item(
                      (data['orderId'] ?? '#-').toString(),
                      (data['status'] ?? 'Placed').toString(),
                      '\$${((data['total'] ?? 0) as num).toStringAsFixed(2)}',
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _item(String id, String status, String total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700)),
                Text(status,
                    style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(total,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
