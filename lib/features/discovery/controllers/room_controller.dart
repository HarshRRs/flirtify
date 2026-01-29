import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/api_service.dart';

class RoomController extends GetxController {
  var isLoading = false.obs;
  var rooms = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
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
}
