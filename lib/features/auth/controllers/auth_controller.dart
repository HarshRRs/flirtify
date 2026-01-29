import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_service.dart';
import '../views/login_screen.dart';
import '../../discovery/views/main_navigation.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var user = {}.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userId', data['_id']);
        user.value = data;
        Get.offAll(() => const MainNavigation());
      } else {
        Get.snackbar('Error', 'Invalid credentials');
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required String gender,
    required List<String> photos,
  }) async {
    try {
      isLoading.value = true;
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'gender': gender,
        'photos': photos,
        'coordinates': [2.3522, 48.8566], // Default Paris for testing
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userId', data['_id']);
        user.value = data;
        Get.offAll(() => const MainNavigation());
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar('Error', error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAll(() => const LoginScreen());
  }

  Future<bool> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}
