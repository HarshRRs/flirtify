import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../../../core/app_colors.dart';
import '../controllers/room_controller.dart';
import 'vibe_room_chat_screen.dart';

class VibeRoomsScreen extends StatelessWidget {
  const VibeRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RoomController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Vibe Rooms', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LineIcons.plusCircle, color: AppColors.primary),
            onPressed: () => _showCreateRoomDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.rooms.length,
          itemBuilder: (context, index) {
            final room = controller.rooms[index];
            return _buildRoomCard(context, room);
          },
        );
      }),
    );
  }

  Widget _buildRoomCard(BuildContext context, dynamic room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: room['isBoosted'] == true ? AppColors.primaryGradient : null,
        color: room['isBoosted'] == true ? null : AppColors.softGrey,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: room['isBoosted'] == true ? Colors.white : AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mood: ${room['mood']}',
                  style: TextStyle(
                    color: room['isBoosted'] == true ? Colors.white70 : AppColors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(LineIcons.users, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${room['participants'].length} active now',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await controller.joinRoom(room['_id']);
              if (success) {
                Get.to(() => VibeRoomChatScreen(room: room));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: room['isBoosted'] == true ? Colors.white : AppColors.primary,
              foregroundColor: room['isBoosted'] == true ? AppColors.primary : Colors.white,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context, RoomController controller) {
    final nameController = TextEditingController();
    final moodController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Create a Vibe Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Room Name (e.g. Paris Nightlife)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: moodController,
              decoration: const InputDecoration(hintText: 'Current Mood'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => controller.createRoom(nameController.text, moodController.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
