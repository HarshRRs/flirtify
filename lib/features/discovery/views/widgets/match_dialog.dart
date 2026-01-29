import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../core/app_colors.dart';

class MatchDialog extends StatelessWidget {
  final Map<String, dynamic> matchData;

  const MatchDialog({super.key, required this.matchData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite,
              color: AppColors.primary,
              size: 80,
            ).animate().scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.2, 1.2),
              duration: 800.ms,
              curve: Curves.easeOutBack,
            ).shake(duration: 800.ms),
            
            const SizedBox(height: 24),
            
            Text(
              "It's a Match!",
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0),
            
            const SizedBox(height: 12),
            
            Text(
              "You and ${matchData['name']} have liked each other.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ).animate().fadeIn(delay: 600.ms),
            
            const SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Navigate to chat
              },
              child: const Text('Send Message'),
            ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2, end: 0),
            
            const SizedBox(height: 16),
            
            OutlinedButton(
              onPressed: () => Get.back(),
              child: const Text('Keep Swiping'),
            ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
