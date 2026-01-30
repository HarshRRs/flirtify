import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Check for auth token here in the future
    await Future.delayed(const Duration(milliseconds: 3500));
    Get.off(
      () => const OnboardingScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          // 1. Dynamic Background Gradient / Mesh
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.dark,
                  ],
                ),
              ),
            ),
          ),

          // 2. Animated Floating Particles (Simulated with Containers)
          ...List.generate(5, (index) {
            return Positioned(
              top: 100.0 * (index + 1),
              left: 50.0 * (index % 3),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                  begin: 0,
                  end: 30,
                  duration: (2000 + (index * 500)).ms,
                  curve: Curves.easeInOut,
                ).blur(begin: const Offset(40, 40), end: const Offset(60, 60));
          }),

          // 3. Main Logo & Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3D Logo Container
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 800))
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutBack,
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: const Duration(seconds: 3), color: Colors.white.withValues(alpha: 0.2))
                    .moveY(begin: -5, end: 5, duration: const Duration(seconds: 2), curve: Curves.easeInOut),

                const SizedBox(height: 60),

                // Premium Typography
                Text(
                  'FLIRTIFY',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 12,
                        fontSize: 32,
                        shadows: [
                          Shadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 500), duration: const Duration(milliseconds: 1000))
                    .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),

                const SizedBox(height: 16),

                // Animated Tagline
                Text(
                  'CHEMISTRY IN EVERY SPARK',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w300,
                      ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 1000), duration: const Duration(milliseconds: 1000))
                    .blur(begin: const Offset(10, 0), end: const Offset(0, 0)),
              ],
            ),
          ),

          // 4. Bottom Progress (Modern Glass)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ).animate().scaleX(
                      begin: 0,
                      end: 1,
                      duration: const Duration(milliseconds: 3000),
                      curve: Curves.easeInOut,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
