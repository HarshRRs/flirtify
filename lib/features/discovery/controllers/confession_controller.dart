import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/api_service.dart';

class ConfessionController extends GetxController {
  var isLoading = false.obs;
  var confessions = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchConfessions();
  }

  Future<void> fetchConfessions() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get('/confessions');
      if (response.statusCode == 200) {
        confessions.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch confessions');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createConfession(String text, bool isAnonymous) async {
    try {
      final response = await ApiService.post('/confessions', {
        'text': text,
        'isAnonymous': isAnonymous,
      });
      if (response.statusCode == 201) {
        fetchConfessions();
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to post confession');
    }
  }

  Future<void> heartConfession(String confessionId) async {
    try {
      final response = await ApiService.post('/confessions/$confessionId/heart', {});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['isMatch']) {
          Get.snackbar('Spicy Match!', 'You matched via a confession!', snackPosition: SnackPosition.BOTTOM);
        }
        fetchConfessions();
      }
    } catch (e) {
      debugPrint('Error hearting confession: $e');
    }
  }
}
