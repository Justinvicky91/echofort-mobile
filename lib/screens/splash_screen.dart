import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _drawAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Drawing animation controller (sketch effect)
    _drawController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade in animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Drawing animation (0 to 1)
    _drawAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _drawController,
        curve: Curves.easeInOut,
      ),
    );

    // Fade animation for text
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    // Glow animation
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations in sequence
    _startAnimations();

    // Navigate after delay
    _navigateToNextScreen();
  }

  Future<void> _startAnimations() async {
    // Start drawing animation
    await _drawController.forward();
    
    // Start fade and glow animations together
    _fadeController.forward();
    _glowController.repeat(reverse: true);
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 3500));

    if (!mounted) return;

    // Check authentication status
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.init();

    if (!mounted) return;

    // Navigate based on auth status
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => authService.isAuthenticated
            ? const DashboardScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _drawController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              const Color(0xFF1a1a2e), // Dark blue-black
              const Color(0xFF0f0f1e), // Darker
              const Color(0xFF000000), // Pure black
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo with sketch drawing effect
              AnimatedBuilder(
                animation: _drawAnimation,
                builder: (context, child) {
                  return AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(
                                0.3 * _glowAnimation.value,
                              ),
                              blurRadius: 40 * _glowAnimation.value,
                              spreadRadius: 10 * _glowAnimation.value,
                            ),
                            BoxShadow(
                              color: Colors.blue.withOpacity(
                                0.2 * _glowAnimation.value,
                              ),
                              blurRadius: 60 * _glowAnimation.value,
                              spreadRadius: 15 * _glowAnimation.value,
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [
                                0.0,
                                _drawAnimation.value,
                                _drawAnimation.value + 0.01,
                                1.0,
                              ],
                              colors: const [
                                Colors.white,
                                Colors.white,
                                Colors.transparent,
                                Colors.transparent,
                              ],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            'assets/images/echofort_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 40),

              // App Name with fade animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'EchoFort',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: Color(0xFF2196F3),
                        blurRadius: 20,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tagline with fade animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'AI-Powered Protection',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFB0B0B0),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Animated loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(
                              0.5 * _glowAnimation.value,
                            ),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary.withOpacity(0.8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
