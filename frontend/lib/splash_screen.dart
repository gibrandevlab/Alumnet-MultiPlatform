import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final String? message;
  const SplashScreen({super.key, this.message});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double progress = 0;
  late Timer timer;
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      setState(() {
        if (progress >= 1.0) {
          progress = 1.0;
        } else {
          progress += (0.12 + (0.15 * (0.5 - (progress % 0.5))));
          if (progress > 1.0) progress = 1.0;
        }
      });
    });
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    timer.cancel();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563eb), // from-blue-600
              Color(0xFF1e40af), // via-blue-700
              Color(0xFF1e293b), // to-blue-900
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: MediaQuery.of(context).size.width * 0.25,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.25,
              right: MediaQuery.of(context).size.width * 0.25,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade200.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo area
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/Logo.png',
                            width: 56,
                            height: 56,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Glow effect
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 60,
                              spreadRadius: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // App Name
                  const Text(
                    'Alumnet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.message ?? 'Loading your experience...',
                    style:
                        const TextStyle(color: Colors.blueAccent, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  // Progress bar
                  Container(
                    width: 220,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 220 * progress,
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.blue.shade200],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Loading dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return AnimatedBuilder(
                        animation: _dotController,
                        builder: (context, child) {
                          double t = (_dotController.value + i * 0.2) % 1.0;
                          double scale = 1 + 0.5 * (1 - (t - 0.5).abs() * 2);
                          double opacity =
                              0.5 + 0.5 * (1 - (t - 0.5).abs() * 2);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 12 * scale,
                            height: 12 * scale,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(opacity),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  // Bottom text
                  const Text(
                    'Powered by Afwan',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
