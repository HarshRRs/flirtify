import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../../../core/app_colors.dart';
import '../controllers/confession_controller.dart';

class ConfessionsScreen extends StatelessWidget {
  const ConfessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConfessionController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Confessions', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LineIcons.edit, color: AppColors.primary),
            onPressed: () => _showCreateConfessionDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.confessions.length,
          itemBuilder: (context, index) {
            final confession = controller.confessions[index];
            return _buildConfessionCard(context, confession, controller);
          },
        );
      }),
    );
  }

  Widget _buildConfessionCard(BuildContext context, dynamic confession, ConfessionController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softGrey,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softPink.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LineIcons.userSecret, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                confession['isAnonymous'] ? 'Anonymous' : 'A User',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            confession['text'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => controller.heartConfession(confession['_id']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(LineIcons.heart, color: AppColors.primary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${confession['hearts'].length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateConfessionDialog(BuildContext context, ConfessionController controller) {
    final textController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Post a Confession'),
        content: TextField(
          controller: textController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Share your spicy secret...'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => controller.createConfession(textController.text, true),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
