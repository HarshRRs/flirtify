import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api_service.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var userProfile = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get('/users/me');
      if (response.statusCode == 200) {
        userProfile.value = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await ApiService.post('/users/profile', data);
      if (response.statusCode == 200) {
        userProfile.value = jsonDecode(response.body);
        Get.snackbar('Success', 'Profile updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      isLoading.value = false;
    }
  }
}
