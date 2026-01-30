import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_colors.dart';
import '../controllers/chat_controller.dart';
// import '../controllers/call_controller.dart'; // Disabled - agora package not available

class ChatDetailScreen extends StatefulWidget {
  final dynamic user;
  const ChatDetailScreen({super.key, required this.user});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _chatController = Get.find<ChatController>();
  // final _callController = Get.put(CallController()); // Disabled - agora package not available
  final _picker = ImagePicker();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _chatController.fetchMessageHistory(widget.user['_id']);
  }

  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });
  }

  Future<void> _pickMedia(bool isVideo) async {
    final XFile? media = isVideo 
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (media != null) {
      final bytes = await File(media.path).readAsBytes();
      final base64Media = base64Encode(bytes);
      _chatController.sendMedia(widget.user['_id'], base64Media, isVideo ? 'video' : 'image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                widget.user['photos'] != null && widget.user['photos'].isNotEmpty
                    ? widget.user['photos'][0]
                    : 'https://i.pravatar.cc/150?img=1',
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark),
                ),
                Text(
                  widget.user['mood'] ?? 'Playful',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt, color: AppColors.primary),
            onPressed: () {
              _chatController.getWingmanSuggestion(widget.user['mood'] ?? 'Playful');
              _showWingmanDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_chatController.isLoadingHistory.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: true,
                itemCount: _chatController.messages.length,
                itemBuilder: (context, index) {
                  final msg = _chatController.messages.reversed.toList()[index];
                  final isMe = msg['senderId'] == _currentUserId;
                  return _buildMessageBubble(msg, isMe);
                },
              );
            }),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isMe) {
    final type = msg['type'] ?? 'text';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: Get.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.softGrey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (type == 'text')
              Text(
                msg['message'],
                style: TextStyle(color: isMe ? Colors.white : AppColors.dark),
              )
            else if (type == 'image')
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(msg['imageUrl']),
                  fit: BoxFit.cover,
                ),
              )
            else if (type == 'video')
              VideoMessagePlayer(videoUrl: msg['videoUrl']),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(DateTime.parse(msg['timestamp'])),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_a_photo, color: AppColors.primary),
              onPressed: () => _pickMedia(false),
            ),
            IconButton(
              icon: const Icon(Icons.videocam, color: AppColors.primary),
              onPressed: () => _pickMedia(true),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type something spicy...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.softGrey,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (_messageController.text.isNotEmpty) {
                  _chatController.sendMessage(widget.user['_id'], _messageController.text);
                  _messageController.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWingmanDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bolt, color: AppColors.primary),
            SizedBox(width: 8),
            Text('AI Wingman'),
          ],
        ),
        content: Obx(() => Text(
              _chatController.icebreaker.value.isEmpty
                  ? 'Thinking of a spicy line...'
                  : '"${_chatController.icebreaker.value}"',
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
            )),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              _messageController.text = _chatController.icebreaker.value;
              Get.back();
            },
            child: const Text('Use this'),
          ),
        ],
      ),
    );
  }
}

class VideoMessagePlayer extends StatefulWidget {
  final String videoUrl;
  const VideoMessagePlayer({super.key, required this.videoUrl});

  @override
  State<VideoMessagePlayer> createState() => _VideoMessagePlayerState();
}

class _VideoMessagePlayerState extends State<VideoMessagePlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // In production, this would be a network URL. For MVP Base64, we'd need to write to a temp file.
    // For now, we assume it's a valid data URI or URL.
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                ),
              ],
            ),
          )
        : const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator())
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
