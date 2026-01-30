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
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/no_matches.png'),
                  ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 40),
                  Text(
                    'NO MORE SPARKS NEARBY',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 12),
                  const Text(
                    'Expand your filters or check back later!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grey500),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: controller.fetchUsers,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.dark,
                    ),
                    child: const Text('REFRESH DISCOVERY'),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
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
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 60,
            spreadRadius: -20,
            offset: const Offset(0, 40),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
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
                        color: AppColors.grey900,
                        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
                top: 15,
                left: 15,
                right: 15,
                child: Row(
                  children: List.generate(
                    allPhotos.length,
                    (index) => Expanded(
                      child: Obx(() => Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: currentPhotoIndex.value == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                if (currentPhotoIndex.value == index)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                  ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ),
            // Glassmorphic Overlay for Text Area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
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
                          color: AppColors.dark,
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
                      color: AppColors.primary.withValues(alpha: 0.8),
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
                            color: Colors.white.withValues(alpha: 0.3),
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: isLarge ? 35 : 28),
    );
  }
}
