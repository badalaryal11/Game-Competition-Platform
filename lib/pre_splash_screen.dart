import 'dart:async';
// *** FIXED: Corrected the typo in the import path ***
import 'package:flutter/material.dart';

class PreSplashScreen extends StatefulWidget {
  const PreSplashScreen({super.key});

  @override
  State<PreSplashScreen> createState() => _PreSplashScreenState();
}

class _PreSplashScreenState extends State<PreSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Create a timer that will navigate to the next splash screen after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        // Navigate to the second splash screen
        Navigator.of(context).pushReplacementNamed('/splash');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/images/pre_splash_image.jpeg', // Use the new image
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
    );
  }
}
