import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/wishlist_provider.dart';
import '../services/firebase_data_service.dart';
import '../theme/app_theme.dart';
import 'admin_panel_screen.dart';
import 'offers_screen.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('darkModeEnabled', _darkModeEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1C1F26),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1C1F26),
                      Color(0xFF2A2F3A),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                    child: StreamBuilder<User?>(
                      stream:
                          FirebaseAuth.instance.authStateChanges(),
                      builder: (context, snap) {
                        final u = snap.data;
                        final name = (u?.displayName != null &&
                                u!.displayName!.trim().isNotEmpty)
                            ? u.displayName!.trim()
                            : 'Member';
                        final email = u?.email ?? '';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                          alpha: 0.35),
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 34,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.12),
                                    backgroundImage: u?.photoURL != null
                                        ? NetworkImage(u!.photoURL!)
                                        : null,
                                    child: u?.photoURL == null
                                        ? Icon(
                                            Icons.person_rounded,
                                            size: 36,
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email.isEmpty
                                            ? 'Fashion Store account'
                                            : email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: Colors.white
                                              .withValues(alpha: 0.72),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Verified shopper',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -18),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _metricsCard(user),
                    const SizedBox(height: 14),
                    _quickRow(context),
                    const SizedBox(height: 20),
                    _groupLabel('Account'),
                    _menuCard(
                      children: [
                        _menuLine(
                          icon: Icons.person_outline_rounded,
                          title: 'Personal details',
                          onTap: _openEditProfile,
                        ),
                        _menuLine(
                          icon: Icons.location_on_outlined,
                          title: 'Addresses',
                          onTap: () {},
                        ),
                        _menuLine(
                          icon: Icons.credit_card_rounded,
                          title: 'Payment methods',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _groupLabel('Shopping'),
                    _menuCard(
                      children: [
                        _menuLine(
                          icon: Icons.favorite_outline_rounded,
                          title: 'Wishlist',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => WishlistScreen()),
                            );
                          },
                        ),
                        _menuLine(
                          icon: Icons.receipt_long_rounded,
                          title: 'Orders',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const OrdersScreen()),
                            );
                          },
                        ),
                        _menuLine(
                          icon: Icons.local_offer_outlined,
                          title: 'Deals & coupons',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => OffersScreen()),
                            );
                          },
                        ),
                        _menuLine(
                          icon: Icons.admin_panel_settings_outlined,
                          title: 'Admin panel',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AdminPanelScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _groupLabel('Preferences'),
                    _prefsCard(),
                    const SizedBox(height: 14),
                    _groupLabel('Support'),
                    _menuCard(
                      children: [
                        _menuLine(
                          icon: Icons.headset_mic_outlined,
                          title: 'Help center',
                          onTap: () {},
                        ),
                        _menuLine(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Message us',
                          onTap: () {},
                        ),
                        _menuLine(
                          icon: Icons.info_outline_rounded,
                          title: 'About',
                          onTap: _openAbout,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _openSignOut,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB42318),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          'Sign out',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricsCard(User? user) {
    final saved = context.watch<WishlistProvider>().count;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8E6E3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: user == null
          ? Text(
              'Sign in to track orders',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('orders')
                  .snapshots(),
              builder: (context, snap) {
                final orderCount = snap.data?.docs.length ?? 0;
                return Row(
                  children: [
                    Expanded(
                      child: _metricCell(
                        value: '$orderCount',
                        label: 'Orders',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFFE8E6E3),
                    ),
                    Expanded(
                      child: _metricCell(
                        value: '$saved',
                        label: 'Saved',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFFE8E6E3),
                    ),
                    Expanded(
                      child: _metricCell(
                        value: '—',
                        label: 'Rewards',
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _metricCell({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _quickRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E6E3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _quickChip(
            context,
            icon: Icons.receipt_long_outlined,
            label: 'Orders',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ),
          ),
          _quickChip(
            context,
            icon: Icons.favorite_border_rounded,
            label: 'Wishlist',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WishlistScreen()),
            ),
          ),
          _quickChip(
            context,
            icon: Icons.local_offer_outlined,
            label: 'Deals',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OffersScreen()),
            ),
          ),
          _quickChip(
            context,
            icon: Icons.support_agent_outlined,
            label: 'Help',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _quickChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: AppColors.textPrimary),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupLabel(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        t.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _menuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E6E3)),
      ),
      child: Column(
        children: _joinDividers(children),
      ),
    );
  }

  List<Widget> _joinDividers(List<Widget> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i < items.length - 1) {
        out.add(Divider(
          height: 1,
          thickness: 1,
          color: const Color(0xFFE8E6E3),
          indent: 52,
        ));
      }
    }
    return out;
  }

  Widget _menuLine({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _prefsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E6E3)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              'Push notifications',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            value: _notificationsEnabled,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.accent;
              }
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary.withValues(alpha: 0.35);
              }
              return null;
            }),
            onChanged: (v) {
              setState(() => _notificationsEnabled = v);
              _savePreferences();
            },
          ),
          Divider(height: 1, color: const Color(0xFFE8E6E3)),
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              'Dark mode',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              'Coming soon',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            value: _darkModeEnabled,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.accent;
              }
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary.withValues(alpha: 0.35);
              }
              return null;
            }),
            onChanged: (v) {
              setState(() => _darkModeEnabled = v);
              _savePreferences();
            },
          ),
        ],
      ),
    );
  }

  void _profileSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor:
            error ? const Color(0xFF2C2C2C) : const Color(0xFF1C1F26),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _openEditProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _profileSnack('Sign in to edit your profile.', error: true);
      return;
    }
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: _EditProfileDialogContent(
          onDismiss: () => Navigator.of(dialogContext).pop(),
          onNotify: _profileSnack,
        ),
      ),
    );
  }

  void _openAbout() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F2EF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_outlined,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Fashion Store',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A marketplace shopping experience built with Flutter. '
                'Orders, wishlists, and catalog sync with your Firebase backend.',
                style: GoogleFonts.plusJakartaSans(
                  height: 1.5,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '© 2026',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1C1F26),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSignOut() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign out',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You will need to sign in again to view orders and saved items.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        _profileSnack('Signed out');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB42318),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Sign out',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfileDialogContent extends StatefulWidget {
  const _EditProfileDialogContent({
    required this.onDismiss,
    required this.onNotify,
  });

  final VoidCallback onDismiss;
  final void Function(String message, {bool error}) onNotify;

  @override
  State<_EditProfileDialogContent> createState() =>
      _EditProfileDialogContentState();
}

class _EditProfileDialogContentState extends State<_EditProfileDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  final _data = FirebaseDataService();
  bool _loadingPhone = true;
  bool _saving = false;

  static const _border = Color(0xFFE8E6E3);
  static const _fill = Color(0xFFF7F6F4);

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _name = TextEditingController(text: user.displayName ?? '');
    _phone = TextEditingController();
    _loadPhone(user.uid);
  }

  Future<void> _loadPhone(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final p = doc.data()?['phone'] as String?;
      if (p != null && mounted) _phone.text = p;
    } finally {
      if (mounted) setState(() => _loadingPhone = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: _fill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final name = _name.text.trim();
      await user.updateDisplayName(name.isEmpty ? null : name);
      await user.reload();
      await _data.upsertUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: name.isEmpty ? null : name,
        phone: _phone.text.trim(),
        mergePhone: true,
      );
      if (!mounted) return;
      widget.onDismiss();
      widget.onNotify('Profile saved');
    } catch (e) {
      if (mounted) {
        widget.onNotify('Could not save profile. Try again.', error: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final email = user.email ?? '';

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal details',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Name and phone are used for delivery and receipts.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : widget.onDismiss,
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: _dec('Full name'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your name';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _fill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.mail_outline_rounded,
                        size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email.isEmpty ? '—' : email,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Secured',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (_loadingPhone)
                const LinearProgressIndicator(minHeight: 2)
              else
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: _dec('Phone', hint: 'Optional'),
                  validator: (v) => null,
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : widget.onDismiss,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: _border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _saving || _loadingPhone ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1C1F26),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save changes',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
