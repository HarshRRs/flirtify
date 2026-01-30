import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../controllers/profile_controller.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'premium_features_screen.dart';
import 'safety_center_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(LineIcons.cog, color: AppColors.primary),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.userProfile.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.userProfile;
        final photoUrl = user['photos'] != null && user['photos'].isNotEmpty
            ? user['photos'][0]
            : 'https://i.pravatar.cc/150?img=33';

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileImage(photoUrl),
                const SizedBox(height: 20),
                Text(
                  '${user['name'] ?? 'Guest'}, ${user['age'] ?? ''}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 5),
                Text(
                  user['mood'] ?? 'Playfully Flirting',
                  style: const TextStyle(color: AppColors.grey),
                ),
                const SizedBox(height: 30),
                _buildStats(Map<String, dynamic>.from(user)),
                const SizedBox(height: 30),
                _buildMenu(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileImage(String photoUrl) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(photoUrl),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => Get.to(() => const EditProfileScreen()),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(Map<String, dynamic> user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Matches', '12'), // Hardcoded for now as backend matches count is needed
        _buildStatItem('Likes', '3.5k'),
        _buildStatItem('Views', '12k'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuItem(LineIcons.userEdit, 'Edit Profile', () => Get.to(() => const EditProfileScreen())),
          _buildMenuItem(LineIcons.heartAlt, 'Premium Features', () => Get.to(() => const PremiumFeaturesScreen())),
          _buildMenuItem(LineIcons.userShield, 'Safety Center', () => Get.to(() => const SafetyCenterScreen())),
          _buildMenuItem(LineIcons.questionCircle, 'Help & Support', () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.softGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
