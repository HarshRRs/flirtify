import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../chat/controllers/chat_controller.dart';

class CallScreen extends StatefulWidget {
  final String roomName;
  final String serverUrl;
  final String subject;
  final String type;
  final dynamic targetUser;

  const CallScreen({
    super.key,
    required this.roomName,
    required this.serverUrl,
    required this.subject,
    required this.type,
    required this.targetUser,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _jitsiMeet = JitsiMeet();

  @override
  void initState() {
    super.initState();
    _joinCall();
  }

  void _joinCall() async {
    final options = JitsiMeetConferenceOptions(
      serverURL: widget.serverUrl,
      room: widget.roomName,
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": widget.type == 'voice',
        "subject": widget.subject,
      },
      featureFlags: {
        "unsecure-connections.enabled": false,
        "ios.screensharing.enabled": false,
        "resolution": 360, // Optimized for mobile
      },
      userInfo: JitsiMeetUserInfo(
        displayName: "Me", // You can pass the local user name here
      ),
    );

    await _jitsiMeet.join(options);
    
    // Once the call is started, Jitsi handles the UI.
    // When the user hangs up, we return to the app.
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    // This is just a fallback while Jitsi is loading
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.call, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              "Connecting to ${widget.targetUser['name']}...",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
