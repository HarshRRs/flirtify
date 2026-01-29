import 'dart:convert';
import 'package:get/get.dart';
import '../views/call_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_service.dart';

class ChatController extends GetxController {
  late IO.Socket socket;
  var messages = [].obs;
  var isConnected = false.obs;
  var isLoadingHistory = false.obs;
  var icebreaker = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initSocket();
  }

  void initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) return;

    // Updated to point to your Railway domain
    socket = IO.io('https://flirtify-production.up.railway.app', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      isConnected.value = true;
      socket.emit('join_chat', userId);
    });

    socket.on('receive_message', (data) {
      messages.add(data);
    });

    socket.onDisconnect((_) {
      isConnected.value = false;
    });
  }

  Future<void> fetchMessageHistory(String otherUserId) async {
    try {
      isLoadingHistory.value = true;
      messages.clear();
      final response = await ApiService.get('/messages/$otherUserId');
      if (response.statusCode == 200) {
        final List history = jsonDecode(response.body);
        messages.addAll(history.map((m) => {
          'senderId': m['sender'],
          'receiverId': m['receiver'],
          'message': m['text'],
          'timestamp': m['timestamp'],
        }));
      }
    } catch (e) {
      print('Error fetching history: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> getWingmanSuggestion(String mood) async {
    try {
      final response = await ApiService.get('/users/wingman?mood=$mood');
      if (response.statusCode == 200) {
        icebreaker.value = jsonDecode(response.body)['icebreaker'];
      }
    } catch (e) {
      print('Wingman error: $e');
    }
  }

  void sendMessage(String receiverId, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getString('userId');

    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': text,
      'type': 'text',
      'timestamp': DateTime.now().toIso8601String(),
    };

    socket.emit('send_message', messageData);
    messages.add(messageData);
    
    // Also save to database
    ApiService.post('/messages', {
      'receiverId': receiverId,
      'text': text,
      'type': 'text',
    });
  }

  void sendMedia(String receiverId, String base64Media, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getString('userId');

    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': type == 'image' ? 'Sent a photo' : 'Sent a video',
      'type': type,
      'imageUrl': type == 'image' ? base64Media : null,
      'videoUrl': type == 'video' ? base64Media : null,
      'timestamp': DateTime.now().toIso8601String(),
    };

    socket.emit('send_message', messageData);
    messages.add(messageData);

    // Also save to database
    ApiService.post('/messages', {
      'receiverId': receiverId,
      'type': type,
      'imageUrl': type == 'image' ? base64Media : null,
      'videoUrl': type == 'video' ? base64Media : null,
    });
  }

  void startCall(dynamic targetUser, String type) async {
    try {
      final response = await ApiService.get('/calls/room?receiverId=${targetUser['_id']}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Notify the target user via socket
        socket.emit('call_user', {
          'userToCall': targetUser['_id'],
          'from': (await SharedPreferences.getInstance()).getString('userId'),
          'name': 'Someone special', 
          'type': type,
          'roomName': data['roomName'],
          'serverUrl': data['serverUrl'],
        });

        // Open CallScreen
        Get.to(() => CallScreen(
          roomName: data['roomName'],
          serverUrl: data['serverUrl'],
          subject: data['subject'],
          type: type,
          targetUser: targetUser,
        ));
      }
    } catch (e) {
      print('Call error: $e');
    }
  }

  void setupIncomingCallListener() {
    socket.on('incoming_call', (data) {
      // Show call dialog or jump to CallScreen
      Get.defaultDialog(
        title: "Incoming ${data['type']} Call",
        middleText: "Accept call from ${data['name']}?",
        textConfirm: "Accept",
        textCancel: "Decline",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          Get.to(() => CallScreen(
            roomName: data['roomName'],
            serverUrl: data['serverUrl'],
            subject: 'Flirtify Private Call',
            type: data['type'],
            targetUser: {'_id': data['from'], 'name': data['name']},
          ));
        },
      );
    });
  }

  @override
  void onClose() {
    socket.dispose();
    super.onClose();
  }
}
