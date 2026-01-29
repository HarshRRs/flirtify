import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../../../core/app_colors.dart';
import 'discovery_screen.dart';
import 'vibe_rooms_screen.dart';
import 'confessions_screen.dart';
import '../../chat/views/chat_list_screen.dart';
import '../../profile/views/profile_screen.dart';

class MainNavigationController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainNavigationController());

    final List<Widget> screens = [
      const DiscoveryScreen(),
      const VibeRoomsScreen(),
      const ConfessionsScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(() => screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(LineIcons.heart),
                activeIcon: Icon(LineIcons.heartAlt),
                label: 'Discovery',
              ),
              BottomNavigationBarItem(
                icon: Icon(LineIcons.users),
                activeIcon: Icon(LineIcons.users),
                label: 'Vibe Rooms',
              ),
              BottomNavigationBarItem(
                icon: Icon(LineIcons.comment),
                activeIcon: Icon(LineIcons.comment),
                label: 'Confessions',
              ),
              BottomNavigationBarItem(
                icon: Icon(LineIcons.comments),
                activeIcon: Icon(LineIcons.commentsAlt),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(LineIcons.user),
                activeIcon: Icon(LineIcons.user),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
