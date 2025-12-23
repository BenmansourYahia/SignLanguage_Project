import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate to home after 5 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.charcoal.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sign_language,
                    size: 80,
                    color: AppColors.charcoal,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // App Name
                const Text(
                  'ASL DETECTOR',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    color: AppColors.charcoal,
                    letterSpacing: 4.0,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  'Real-time Sign Language Recognition',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.charcoal.withOpacity(0.6),
                    letterSpacing: 1.0,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Loading indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.charcoal.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
