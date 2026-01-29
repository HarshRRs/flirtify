import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/app_colors.dart';
import '../controllers/room_controller.dart';

class VibeRoomChatScreen extends StatefulWidget {
  final dynamic room;
  const VibeRoomChatScreen({super.key, required this.room});

  @override
  State<VibeRoomChatScreen> createState() => _VibeRoomChatScreenState();
}

class _VibeRoomChatScreenState extends State<VibeRoomChatScreen> {
  final _messageController = TextEditingController();
  final _roomController = Get.find<RoomController>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to bottom when new messages arrive
    ever(_roomController.roomMessages, (_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: widget.room['isBoosted'] == true 
                ? AppColors.primaryGradient.withOpacity(0.8) 
                : LinearGradient(
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.room['name'],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${widget.room['participants'].length} vibing • ${widget.room['mood']}',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LineIcons.infoCircle, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1514525253361-bee8a187499b?auto=format&fit=crop&w=1200&q=80'
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(() => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 120, 16, 20),
                itemCount: _roomController.roomMessages.length,
                itemBuilder: (context, index) {
                  final msg = _roomController.roomMessages[index];
                  // In a real app, check if sender is ME
                  final isMe = msg['senderId'] == _roomController.chatController.socket.id;
                  return _buildMessageBubble(msg, isMe);
                },
              )),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                'Stranger', // In production, use msg['senderName']
                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: Get.width * 0.75),
            decoration: BoxDecoration(
              color: isMe 
                  ? AppColors.primary.withOpacity(0.9) 
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Text(
              msg['message'],
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: isMe ? 0.2 : -0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add to the vibe...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (_messageController.text.isNotEmpty) {
                  _roomController.sendRoomMessage(widget.room['_id'], _messageController.text);
                  _messageController.clear();
                  _scrollToBottom();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LineIcons.paperPlane, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
