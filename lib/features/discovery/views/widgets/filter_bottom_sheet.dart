import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/app_colors.dart';
import '../../controllers/discovery_controller.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiscoveryController>();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.white 
                      : AppColors.dark,
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Age Range
          Text(
            'Age Range',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Obx(() => RangeSlider(
            values: controller.ageRange.value,
            min: 18,
            max: 80,
            divisions: 62,
            activeColor: AppColors.primary,
            labels: RangeLabels(
              controller.ageRange.value.start.round().toString(),
              controller.ageRange.value.end.round().toString(),
            ),
            onChanged: (values) => controller.ageRange.value = values,
          )),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${controller.ageRange.value.start.round()} years'),
              Text('${controller.ageRange.value.end.round()} years'),
            ],
          )),
          const SizedBox(height: 32),
          // Max Distance
          Text(
            'Maximum Distance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Obx(() => Slider(
            value: controller.maxDistance.value,
            min: 1,
            max: 200,
            divisions: 199,
            activeColor: AppColors.primary,
            label: '${controller.maxDistance.value.round()} km',
            onChanged: (value) => controller.maxDistance.value = value,
          )),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('1 km'),
              Text('${controller.maxDistance.value.round()} km'),
            ],
          )),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              controller.fetchUsers();
              Get.back();
            },
            child: const Text('Apply Filters'),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                controller.ageRange.value = const RangeValues(18, 50);
                controller.maxDistance.value = 50;
                controller.fetchUsers();
                Get.back();
              },
              child: const Text('Reset to Default'),
            ),
          ),
        ],
      ),
    );
  }
}
