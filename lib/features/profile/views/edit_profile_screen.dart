import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../../../core/app_colors.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final controller = Get.find<ProfileController>();
  late TextEditingController _bioController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: controller.userProfile['bio'] ?? '');
    _nameController = TextEditingController(text: controller.userProfile['name'] ?? '');
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              controller.updateProfile({
                'name': _nameController.text,
                'bio': _bioController.text,
              });
              Get.back();
            },
            child: const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Photos'),
            const SizedBox(height: 16),
            _buildPhotoGrid(),
            const SizedBox(height: 32),
            _buildSectionTitle('Basics'),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell them something spicy...',
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('My Prompts'),
            const SizedBox(height: 16),
            _buildPromptTile("My ideal date involves...", "Wine tasting in Paris."),
            _buildPromptTile("A fun fact about me...", "I've visited 40 countries."),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPhotoGrid() {
    final photos = controller.userProfile['photos'] as List? ?? [];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        final hasPhoto = index < photos.length;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
          ),
          child: hasPhoto
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(photos[index], fit: BoxFit.cover),
                )
              : const Icon(Icons.add_a_photo_outlined, color: AppColors.grey400),
        );
      },
    );
  }

  Widget _buildPromptTile(String prompt, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prompt, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(answer, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
