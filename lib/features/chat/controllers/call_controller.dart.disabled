import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../core/api_service.dart';
import '../../chat/controllers/chat_controller.dart';
import '../views/call_screen.dart';

class CallController extends GetxController {
  final _chatController = Get.find<ChatController>();
  var isIncomingCall = false.obs;
  var incomingCallData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    _listenForCalls();
  }

  void _listenForCalls() {
    _chatController.socket.on('incoming_call', (data) {
      incomingCallData.value = data;
      isIncomingCall.value = true;
      _showIncomingCallDialog(data);
    });

    _chatController.socket.on('call_ended', (_) {
      Get.back();
      isIncomingCall.value = false;
    });
  }

  void startCall(dynamic targetUser, String type) async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    final channelName = 'call_${DateTime.now().millisecondsSinceEpoch}';
    
    // Get token from backend
    final response = await ApiService.get('/calls/token?channelName=$channelName&role=publisher');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Signal user via socket
      _chatController.socket.emit('call_user', {
        'userToCall': targetUser['_id'],
        'from': _chatController.socket.id,
        'name': 'Me', // Should be current user name
        'type': type,
        'channelName': channelName
      });

      Get.to(() => CallScreen(
        channelName: channelName,
        token: data['token'],
        appId: data['appId'],
        type: type,
        targetUser: targetUser,
      ));
    }
  }

  void acceptCall() async {
    final data = incomingCallData.value;
    isIncomingCall.value = false;

    // Get token
    final response = await ApiService.get('/calls/token?channelName=${data['channelName']}&role=publisher');
    
    if (response.statusCode == 200) {
      final tokenData = jsonDecode(response.body);
      
      _chatController.socket.emit('answer_call', {
        'to': data['from'],
        'accepted': true
      });

      Get.to(() => CallScreen(
        channelName: data['channelName'],
        token: tokenData['token'],
        appId: tokenData['appId'],
        type: data['type'],
        targetUser: {'name': data['name']}, // Minimal for UI
      ));
    }
  }

  void rejectCall() {
    final data = incomingCallData.value;
    _chatController.socket.emit('answer_call', {
      'to': data['from'],
      'accepted': false
    });
    isIncomingCall.value = false;
    Get.back();
  }

  void _showIncomingCallDialog(dynamic data) {
    Get.dialog(
      AlertDialog(
        title: Text('Incoming ${data['type']} call'),
        content: Text('${data['name']} is calling you...'),
        actions: [
          TextButton(onPressed: rejectCall, child: const Text('Reject', style: TextStyle(color: Colors.red))),
          ElevatedButton(onPressed: acceptCall, child: const Text('Accept')),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
