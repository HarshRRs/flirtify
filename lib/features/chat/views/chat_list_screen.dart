import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api_service.dart';
import '../controllers/chat_controller.dart';
import 'chat_detail_screen.dart';
import 'dart:convert';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  var matches = [].obs;
  var isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    try {
      final response = await ApiService.get('/users/discovery'); // Reusing discovery for now or should be /matches
      if (response.statusCode == 200) {
        matches.value = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching matches: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Matches',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNewMatches(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Messages',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(child: _buildMessagesList(controller)),
          ],
        );
      }),
    );
  }

  Widget _buildMessagesList(ChatController controller) {
    if (matches.isEmpty) {
      return const Center(child: Text('No matches yet. Keep swiping!'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: matches.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = matches[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              user['photos'] != null && user['photos'].isNotEmpty
                  ? user['photos'][0]
                  : 'https://i.pravatar.cc/150?img=1',
            ),
          ),
          title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(user['mood'] ?? 'Playful', maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => Get.to(() => ChatDetailScreen(user: user)),
        );
      },
    );
  }

  Widget _buildNewMatches() {
    if (matches.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: matches.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => Get.to(() => ChatDetailScreen(user: matches[index])),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        matches[index]['photos'] != null && matches[index]['photos'].isNotEmpty
                            ? matches[index]['photos'][0]
                            : 'https://i.pravatar.cc/150?img=1',
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(matches[index]['name'],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
