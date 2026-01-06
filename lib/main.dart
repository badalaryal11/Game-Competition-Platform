import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'signin_screen.dart';
import 'game_screen.dart';
import 'splash_screen.dart';
import 'signup_screen.dart';
import 'pre_splash_screen.dart';
import 'privacy_screen.dart';
import 'phone_verification_screen.dart';
import 'otp_screen.dart';
import 'onboarding_screen.dart';
import 'landing_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For desktop
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // For web
import 'dart:io' show Platform; // For platform detection
import 'package:flutter/foundation.dart'
    show kIsWeb; // Required for kIsWeb check
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Explicitly allow all orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Set the new pre-splash screen as the initial route
      initialRoute: '/pre-splash',
      routes: {
        '/pre-splash': (context) => const PreSplashScreen(),
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const SignInScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/privacy': (context) => const PrivacyScreen(),
        '/phone-verify': (context) => const PhoneVerificationScreen(),
        '/otp': (context) => const OtpScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/landing': (context) => const LandingPage(),
        '/game': (context) => const GameScreen(),
      },
    );
  }
}
