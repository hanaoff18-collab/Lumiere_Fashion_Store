import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  /// Matches the id shown after checkout (e.g. `ORD48291`).
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4),
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 40,
                right: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.success, AppColors.success.withOpacity(0.75)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.4),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'You are all set!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Thank you — your order is confirmed.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Order #$orderId',
                            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Estimated delivery: 3–5 business days',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    FilledButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Back to shopping',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _showTrackOrderSheet(context, orderId),
                      child: Text(
                        'Track order',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showTrackOrderSheet(BuildContext context, String orderId) {
  final steps = [
    ('Order placed', 'We received your order.', true),
    ('Processing', 'Items are being prepared.', true),
    ('Shipped', 'Package handed to the carrier.', false),
    ('Out for delivery', 'Expected within 3–5 business days.', false),
  ];

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Track order',
                  style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '#$orderId',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                ...steps.map((s) {
                  final done = s.$3;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done ? AppColors.success : AppColors.outline.withOpacity(0.35),
                          ),
                          child: Icon(
                            done ? Icons.check_rounded : Icons.schedule_rounded,
                            size: 16,
                            color: done ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.$1,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: done ? AppColors.textPrimary : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.$2,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Text(
                  'Tracking updates are simulated for this demo.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.85)),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
