import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/app_colors.dart';

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
        "prejoinPageEnabled": false, // Skip prejoin for premium feel
      },
      featureFlags: {
        "unsecure-connections.enabled": false,
        "ios.screensharing.enabled": false,
        "resolution": 360,
        "call-integration.enabled": true, // Better OS integration
      },
      userInfo: JitsiMeetUserInfo(
        displayName: "Sender", // Should ideally be current users name
      )
    );

    await _jitsiMeet.join(options);
    
    // When Jitsi closes, we'll hit this line and return
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Animated Background Glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ).animate(onPlay: (c) => c.repeat()).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.5, 1.5),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
            ).fadeOut(),
          ),
          
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 60, color: AppColors.primary),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    widget.type == 'video' ? "Iniciating Video Call..." : "Calling...",
                    style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: const Duration(seconds: 1)).fadeOut(delay: 500.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    widget.targetUser['name'] ?? "Someone Special",
                    style: const TextStyle(color: AppColors.dark, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  
                  const Spacer(),
                  
                  // Cancel Button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call_end, color: Colors.white, size: 30),
                    ),
                  ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
