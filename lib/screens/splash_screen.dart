import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // iOS Icons & Loaders
import 'dart:async';
import 'login_screen.dart'; // Splash eken passe Login ekata yanna

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Animation ekata ona variables
  double _opacity = 0.0;
  double _scale = 0.8;

  // Premium Colors (iOS Style)
  final Color darkBlue = const Color(0xFF0A1D37);
  final Color premiumGreen = const Color(0xFF00C7BE);

  @override
  void initState() {
    super.initState();

    // App eka on wela milliseconds 100kin lassanata fade wela logo eka enawa
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    // Thathpara 3kata passe Login Screen ekata auto yanawa
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Apple Style Premium Gradient Background Eka
          gradient: LinearGradient(
            colors: [Color(0xFF142850), darkBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // --- ANIMATED LOGO SECTION ---
            AnimatedOpacity(
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOut,
              opacity: _opacity,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutBack,
                scale: _scale,
                child: Column(
                  children: [
                    // Icon Background Glow Effect
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: premiumGreen.withValues(alpha: 0.2),
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.bus,
                        size: 70,
                        color: premiumGreen,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // App Name
                    const Text(
                      'NSBM SHUTTLE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Smart Transport System',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // --- BOTTOM LOADING INDICATOR & DEVELOPER NAME ---
            AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: _opacity,
              child: Column(
                children: [
                  const CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 15,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Powered by Mrd', // <-- Methana thama wenas kale
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
