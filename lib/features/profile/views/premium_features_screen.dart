import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import '../../../core/app_colors.dart';

class PremiumFeaturesScreen extends StatelessWidget {
  const PremiumFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Flirtify Gold'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Column(
                children: [
                  Icon(LineIcons.crown, color: Colors.white, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'Go Premium',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Get the best of Flirtify',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildFeatureTile(LineIcons.heart, 'Unlimited Likes', 'Never run out of potential matches.'),
            _buildFeatureTile(LineIcons.undo, 'Unlimited Rewinds', 'Accidentally swiped left? Bring them back.'),
            _buildFeatureTile(LineIcons.mapMarker, 'Passport', 'Match with people anywhere in the world.'),
            _buildFeatureTile(LineIcons.eye, 'See Who Likes You', 'Skip the swipe and match instantly.'),
            
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Unlock Flirtify Gold'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.softPink,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(description, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
