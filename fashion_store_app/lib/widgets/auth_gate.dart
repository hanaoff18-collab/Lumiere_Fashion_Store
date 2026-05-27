import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';

/// While `true`, [AuthGate] keeps showing [LoginScreen] even if a user session
/// exists (e.g. during email registration before [FirebaseAuth.signOut]).
/// Prevents a flash of [HomeScreen] after `createUserWithEmailAndPassword`.
class AuthFlowFlags {
  AuthFlowFlags._();
  static bool deferHomeDuringRegistration = false;
}

/// Routes to [LoginScreen] or [HomeScreen] based on Firebase Auth state.
///
/// Does **not** block on [ConnectionState.waiting] — on some devices the auth
/// stream can stay in "waiting" too long. We use [initialData] + stream data
/// so signed-in users see the app immediately; signed-out users see login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user != null && !AuthFlowFlags.deferHomeDuringRegistration) {
          return const HomeScreen();
        }

        // Signed out: show login. Avoid a full-screen loader that never ends
        // if the stream is slow to emit on certain devices / networks.
        return const LoginScreen();
      },
    );
  }
}
