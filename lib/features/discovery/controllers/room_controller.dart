import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/api_service.dart';
import '../../chat/controllers/chat_controller.dart';

class RoomController extends GetxController {
  var isLoading = false.obs;
  var rooms = [].obs;
  var roomMessages = [].obs;
  final chatController = Get.find<ChatController>();

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
    _listenToRoomMessages();
  }

  void _listenToRoomMessages() {
    chatController.socket.on('receive_room_message', (data) {
      roomMessages.add(data);
    });
  }

  Future<void> fetchRooms() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get('/rooms');
      if (response.statusCode == 200) {
        rooms.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch vibe rooms');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createRoom(String name, String mood) async {
    try {
      final response = await ApiService.post('/rooms', {
        'name': name,
        'mood': mood,
      });
      if (response.statusCode == 201) {
        fetchRooms();
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create room');
    }
  }

  Future<bool> joinRoom(String roomId) async {
    try {
      final response = await ApiService.post('/rooms/$roomId/join', {});
      if (response.statusCode == 200) {
        // Clear old messages and join the socket room
        roomMessages.clear();
        chatController.socket.emit('join_vibe_room', roomId);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to join room');
      return false;
    }
  }

  void sendRoomMessage(String roomId, String message) {
    if (message.isEmpty) return;
    
    final messageData = {
      'roomId': roomId,
      'senderId': chatController.socket.id, // Or use actual userId
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    chatController.socket.emit('send_room_message', messageData);
    // Optimistic UI update
    roomMessages.add(messageData);
  }
}
