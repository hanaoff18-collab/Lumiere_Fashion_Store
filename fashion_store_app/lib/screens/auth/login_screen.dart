import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/motion_3d.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  late AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_mapAuthError(e),
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Something went wrong. Try again.',
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment and try again.';
      default:
        return e.message ?? 'Sign-in failed (${e.code}).';
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter your email above, then tap Forgot password.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check your inbox for a reset link.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = 'Could not send email. Try again.';
      if (e.code == 'user-not-found') msg = 'No account found for that email.';
      if (e.code == 'invalid-email') msg = 'That email looks invalid.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg,
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600))),
      );
    } finally {
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
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
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: CurvedAnimation(
                        parent: _entrance, curve: Curves.easeOutCubic),
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.12), end: Offset.zero)
                          .animate(
                        CurvedAnimation(
                            parent: _entrance, curve: Curves.easeOutCubic),
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
                                    'Welcome back',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Use the email and password for your account.',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        height: 1.35),
                                  ),
                                  const SizedBox(height: 22),
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    decoration: const InputDecoration(
                                        labelText: 'Email'),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return 'Required';
                                      if (!v.contains('@'))
                                        return 'Enter a valid email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _password,
                                    obscureText: _obscure,
                                    autofillHints: const [
                                      AutofillHints.password
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                            () => _obscure = !_obscure),
                                        icon: Icon(_obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Required';
                                      if (v.length < 6)
                                        return 'At least 6 characters';
                                      return null;
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed:
                                          _busy ? null : _sendPasswordReset,
                                      child: Text(
                                        'Forgot password?',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  FilledButton(
                                    onPressed: _busy ? null : _submit,
                                    style: FilledButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 52),
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                    ),
                                    child: _busy
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white))
                                        : Text('Sign in',
                                            style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16)),
                                  ),
                                  const SizedBox(height: 18),
                                  TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const RegisterScreen()),
                                            );
                                          },
                                    child: Text(
                                      'Create an account',
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
