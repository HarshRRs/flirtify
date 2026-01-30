import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../core/api_service.dart';

class HeatMapScreen extends StatefulWidget {
  const HeatMapScreen({super.key});

  @override
  State<HeatMapScreen> createState() => _HeatMapScreenState();
}

class _HeatMapScreenState extends State<HeatMapScreen> {
  var clusters = [].obs;
  var isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    fetchHeatMap();
  }

  Future<void> fetchHeatMap() async {
    try {
      final response = await ApiService.get('/users/heatmap');
      if (response.statusCode == 200) {
        clusters.value = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching heatmap: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heat Map'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() => isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(48.8566, 2.3522), // Paris
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.flirtify.flirtify',
                ),
                MarkerLayer(
                  markers: clusters.map((c) {
                    return Marker(
                      point: LatLng(c['_id']['lat'], c['_id']['lng']),
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${c['count']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            )),
    );
  }
}
