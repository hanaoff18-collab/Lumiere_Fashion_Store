import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/firebase_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_gate.dart';
import '../../widgets/motion_3d.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _busy = false;
  late AnimationController _entrance;
  final FirebaseDataService _dataService = FirebaseDataService();

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    var createdAccount = false;
    AuthFlowFlags.deferHomeDuringRegistration = true;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      createdAccount = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final display = _name.text.trim();
        if (display.isNotEmpty) {
          await user.updateDisplayName(display);
          await user.reload();
        }
        await _dataService.upsertUserProfile(
          uid: user.uid,
          email: user.email ?? _email.text.trim(),
          displayName: display.isEmpty ? null : display,
        );
      }
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created. Sign in with your email and password.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = e.message ?? 'Registration failed';
      if (e.code == 'email-already-in-use') {
        msg = 'That email is already registered. Sign in instead.';
      }
      if (e.code == 'weak-password') msg = 'Password is too weak.';
      if (e.code == 'invalid-email') msg = 'That email looks invalid.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong. Try again.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
        ),
      );
    } finally {
      if (createdAccount && FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
      AuthFlowFlags.deferHomeDuringRegistration = false;
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.95),
                      ),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LUMIÈRE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entrance,
                      curve: Curves.easeOutCubic,
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.12),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _entrance,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(-0.028),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 32,
                                offset: const Offset(0, 18),
                              ),
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                blurRadius: 48,
                                offset: const Offset(0, 22),
                              ),
                            ],
                          ),
                          child: GlassPanel(
                            borderRadius: 26,
                            blur: 24,
                            opacity: 0.88,
                            child: Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'New member',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Use a strong password. You can update details later in your profile.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  TextFormField(
                                    controller: _name,
                                    textCapitalization: TextCapitalization.words,
                                    autofillHints: const [AutofillHints.name],
                                    decoration: const InputDecoration(
                                      labelText: 'Full name',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      if (!v.contains('@')) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _password,
                                    obscureText: _obscurePassword,
                                    autofillHints: const [AutofillHints.newPassword],
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscurePassword = !_obscurePassword,
                                        ),
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Required';
                                      }
                                      if (v.length < 6) {
                                        return 'At least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _confirm,
                                    obscureText: _obscureConfirm,
                                    autofillHints: const [AutofillHints.newPassword],
                                    decoration: InputDecoration(
                                      labelText: 'Confirm password',
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscureConfirm = !_obscureConfirm,
                                        ),
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v != _password.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 22),
                                  FilledButton(
                                    onPressed: _busy ? null : _submit,
                                    style: FilledButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 52),
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _busy
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Create account',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 18),
                                  TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () => Navigator.pop(context),
                                    child: Text(
                                      'Already have an account? Sign in',
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
                          ),
                        ),
                      ),
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
