import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  Object? firebaseInitError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (kReleaseMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
    } else {
      // Keep debug builds fast and avoid token retry loops while developing.
      debugPrint('App Check disabled for debug build.');
    }
  } catch (e, st) {
    debugPrint('Firebase.initializeApp failed: $e\n$st');
    firebaseInitError = e;
  }
  runApp(MyApp(firebaseInitError: firebaseInitError));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.firebaseInitError});

  /// If set, Firebase failed to start — show error instead of auth (e.g. bad config).
  final Object? firebaseInitError;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => WishlistProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Fashion Store',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: firebaseInitError != null
            ? _FirebaseInitErrorScreen(error: firebaseInitError!)
            : const AuthGate(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}

class _FirebaseInitErrorScreen extends StatelessWidget {
  const _FirebaseInitErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Firebase could not start', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              const Text(
                'Check google-services.json, firebase_options.dart, and that Google Play services is up to date on your device.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
