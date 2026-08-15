import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pushReplacementNamed(context, '/onboarding'));
    return const Scaffold(
      body: Center(child: Text('ProxiUPI — Splash')),
    );
  }
}
