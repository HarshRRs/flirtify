import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/app_colors.dart';
import 'heatmap_screen.dart';
import '../controllers/discovery_controller.dart';
import 'widgets/filter_bottom_sheet.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DiscoveryController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Flirtify',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(LineIcons.mapMarker, color: AppColors.primary),
            onPressed: () => Get.to(() => const HeatMapScreen()),
          ),
          IconButton(
            icon: const Icon(LineIcons.horizontalSliders, color: AppColors.primary),
            onPressed: () => Get.bottomSheet(
              const FilterBottomSheet(),
              isScrollControlled: true,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LineIcons.heartBroken, size: 60, color: AppColors.grey),
                const SizedBox(height: 16),
                const Text('No more sparks nearby!', style: TextStyle(color: AppColors.grey)),
                TextButton(onPressed: controller.fetchUsers, child: const Text('Refresh')),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: controller.users.map((userData) {
                    return _buildDiscoveryCard(
                      context,
                      name: userData['name'],
                      age: userData['age'],
                      mood: userData['mood'] ?? 'Playful',
                      imageUrl: userData['photos'] != null && userData['photos'].isNotEmpty
                          ? userData['photos'][0]
                          : 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
                      onLike: () => controller.likeUser(userData['_id']),
                      onDislike: () => controller.dislikeUser(userData['_id']),
                      voiceUrl: userData['voiceTeaser'],
                      allPhotos: userData['photos'],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutBack);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      controller.dislikeUser(controller.users.first['_id']);
                    },
                    child: _buildActionButton(Icons.close, Colors.white, AppColors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      controller.likeUser(controller.users.first['_id']);
                    },
                    child: _buildActionButton(Icons.favorite, AppColors.primary, AppColors.white, isLarge: true),
                  ),
                  _buildActionButton(Icons.star, Colors.white, Colors.amber),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDiscoveryCard(
    BuildContext context, {
    required String name,
    required int age,
    required String mood,
    required String imageUrl,
    required VoidCallback onLike,
    required VoidCallback onDislike,
    String? voiceUrl,
    List<dynamic>? allPhotos,
  }) {
    final controller = Get.find<DiscoveryController>();
    var currentPhotoIndex = 0.obs;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Obx(() {
              final imageSrc = allPhotos != null && allPhotos.isNotEmpty
                  ? allPhotos[currentPhotoIndex.value]
                  : imageUrl;
              
              final isNetwork = imageSrc.startsWith('http');

              return isNetwork
                  ? CachedNetworkImage(
                      imageUrl: imageSrc,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppColors.grey200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  : Image.memory(
                      base64Decode(imageSrc),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    );
            }),
            // Left/Right tapping for photo navigation
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (currentPhotoIndex.value > 0) {
                        HapticFeedback.selectionClick();
                        currentPhotoIndex.value--;
                      }
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (allPhotos != null && currentPhotoIndex.value < allPhotos.length - 1) {
                        HapticFeedback.selectionClick();
                        currentPhotoIndex.value++;
                      }
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
            // Photo Indicators
            if (allPhotos != null && allPhotos.length > 1)
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: List.generate(
                    allPhotos.length,
                    (index) => Expanded(
                      child: Obx(() => Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: currentPhotoIndex.value == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )),
                    ),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$name, $age',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (c) => c.repeat()).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.5, 1.5),
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      mood,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (voiceUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () => controller.playVoiceTeaser(voiceUrl),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.volume_up, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color bgColor, Color iconColor, {bool isLarge = false}) {
    return Container(
      width: isLarge ? 70 : 56,
      height: isLarge ? 70 : 56,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: isLarge ? 35 : 28),
    );
  }
}
