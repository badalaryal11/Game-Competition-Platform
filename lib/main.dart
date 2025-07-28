import 'package:flutter/material.dart';
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GCP Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),

      // Set the new pre-splash screen as the initial route
      initialRoute: '/pre-splash',

      routes: {
        '/pre-splash': (context) => const PreSplashScreen(),
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const SignInScreen(),
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
