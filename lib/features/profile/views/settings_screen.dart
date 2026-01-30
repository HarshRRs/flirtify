import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../../../core/app_colors.dart';
import '../../../core/theme_controller.dart';
import '../controllers/profile_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Appearance'),
          Obx(() => _buildSettingsTile(
            LineIcons.moon,
            'Dark Mode',
            () => themeController.toggleTheme(!themeController.isDarkMode.value),
            trailing: _buildSwitch(
              themeController.isDarkMode.value,
              (val) => themeController.toggleTheme(val)
            )
          )),
          const SizedBox(height: 24),

          _buildSection('Account'),
          _buildSettingsTile(LineIcons.user, 'Personal Information', () {}),
          _buildSettingsTile(LineIcons.envelope, 'Email Address', () {}),
          _buildSettingsTile(LineIcons.phone, 'Phone Number', () {}),
          
          const SizedBox(height: 24),
          _buildSection('Privacy'),
          _buildSettingsTile(LineIcons.lock, 'Blocked Users', () {}),
          _buildSettingsTile(LineIcons.eye, 'Profile Visibility', () {}, trailing: _buildSwitch(true, (v) {})),
          _buildSettingsTile(LineIcons.mapMarker, 'Location Sharing', () {}, trailing: _buildSwitch(true, (v) {})),

          const SizedBox(height: 24),
          _buildSection('Notifications'),
          _buildSettingsTile(LineIcons.bell, 'Push Notifications', () {}, trailing: _buildSwitch(true, (v) {})),
          _buildSettingsTile(LineIcons.comment, 'New Matches', () {}, trailing: _buildSwitch(true, (v) {})),

          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              // Sign out logic
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Sign Out'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text('Delete Account', style: TextStyle(color: AppColors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}
