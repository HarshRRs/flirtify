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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Glow
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
              ),
            ).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(2.5, 2.5),
                  duration: 3.seconds,
                  curve: Curves.easeOutExpo,
                ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 1200.ms,
                      curve: Curves.easeInOut,
                    )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),

                const SizedBox(height: 40),

                // App Name
                Text(
                  'Flirtify',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.white 
                            : AppColors.dark,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 800.ms)
                    .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),

                const SizedBox(height: 12),

                // Tagline
                Text(
                  'Chemistry in every swipe.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.grey500,
                        letterSpacing: 1.2,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 800.ms)
                    .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
              ],
            ),

            // Loading Indicator at bottom
            Positioned(
              bottom: 80,
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ).animate().fadeIn(delay: 1500.ms),
            ),
          ],
        ),
      ),
    );
  }
}
