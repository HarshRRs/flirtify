import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/api_service.dart';
import '../views/widgets/match_dialog.dart';

class DiscoveryController extends GetxController {
  var isLoading = false.obs;
  var users = [].obs;
  
  // Filters
  var ageRange = const RangeValues(18, 50).obs;
  var maxDistance = 50.0.obs;
  var selectedMood = 'All'.obs;

  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  Future<void> playVoiceTeaser(String url) async {
    try {
      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(url));
    } catch (e) {
      Get.snackbar('Error', 'Failed to play voice teaser');
    }
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final queryParams = {
        'minAge': ageRange.value.start.round().toString(),
        'maxAge': ageRange.value.end.round().toString(),
        'maxDistance': maxDistance.value.round().toString(),
      };
      
      final queryString = Uri(queryParameters: queryParams).query;
      final response = await ApiService.get('/users/discovery?$queryString');
      
      if (response.statusCode == 200) {
        users.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> likeUser(String targetUserId) async {
    try {
      final response = await ApiService.post('/users/like', {
        'targetUserId': targetUserId,
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['isMatch']) {
          final matchedUser = users.firstWhere((u) => u['_id'] == targetUserId);
          Get.dialog(MatchDialog(matchData: matchedUser));
        }
        users.removeWhere((u) => u['_id'] == targetUserId);
      }
    } catch (e) {
      debugPrint('Error liking user: $e');
    }
  }

  Future<void> dislikeUser(String targetUserId) async {
    try {
      await ApiService.post('/users/dislike', {
        'targetUserId': targetUserId,
      });
      users.removeWhere((u) => u['_id'] == targetUserId);
    } catch (e) {
      debugPrint('Error disliking user: $e');
    }
  }
}
