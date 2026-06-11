import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:runvix/export.dart';
import '../../../../Component/StatComponent.dart';

class ProfileProgressTab extends StatelessWidget {
  const ProfileProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return RefreshIndicator(
      onRefresh: () => controller.fetchUserWorkouts(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildActivitySelector(),
              const SizedBox(height: 24),
              _buildThisWeekSection(controller),
              const Divider(
                height: 40,
                thickness: 8,
                color: AppColors.dividerGrey,
              ),
              _buildOverallStatsSection(controller),
              const SizedBox(height: 24),
              _buildRouteMapSection(controller),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.buttonColor.withOpacity(0.5)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_run, size: 18, color: AppColors.buttonColor),
            SizedBox(width: 8),
            Text(
              'Chạy bộ',
              style: TextStyle(
                color: AppColors.buttonColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThisWeekSection(ProfileController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoạt động gần đây',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatItem(
                label: 'Tổng quãng đường',
                value:
                    '${(controller.totalDistance.value / 1000).toStringAsFixed(2)} km',
              ),
              StatItem(
                label: 'Số buổi tập',
                value: '${controller.workoutCount.value}',
              ),
              StatItem(
                label: 'Thời gian',
                value:
                    '${(controller.totalDuration.value / 60).toStringAsFixed(0)} phút',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatsSection(ProfileController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thành tích cá nhân',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Obx(
            () => StatRow(
              icon: Icons.emoji_events_outlined,
              title: "Quãng đường dài nhất",
              value:
                  "${(controller.maxDistance.value / 1000).toStringAsFixed(2)} km",
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final pace = controller.bestPace.value;
            String paceStr = "-:-- /km";
            if (pace > 0) {
              int mins = pace ~/ 60;
              int secs = (pace % 60).toInt();
              paceStr = "$mins:${secs.toString().padLeft(2, '0')} /km";
            }
            return StatRow(
              icon: Icons.speed,
              title: "Nhịp độ nhanh nhất",
              value: paceStr,
            );
          }),
          const SizedBox(height: 12),
          Obx(() {
            final duration = controller.maxDuration.value;
            int hours = duration ~/ 3600;
            int mins = (duration % 3600) ~/ 60;
            int secs = duration % 60;
            String timeStr =
                "${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
            return StatRow(
              icon: Icons.timer_outlined,
              title: "Thời gian lâu nhất",
              value: timeStr,
            );
          }),
        ],
      ),
    );
  }
  Widget _buildRouteMapSection(ProfileController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bản đồ tuyến đường',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.workouts.isEmpty) {
              return Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Chưa có dữ liệu lộ trình',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            // Lấy ra tuyến đường chạy dài nhất
            Set<Polyline> polylines = {};
            LatLng? firstPoint;

            WorkoutModel? longestWorkout;
            for (var w in controller.workouts) {
              if (w.route.isNotEmpty) {
                if (longestWorkout == null ||
                    w.distance > longestWorkout.distance) {
                  longestWorkout = w;
                }
              }
            }

            if (longestWorkout != null) {
              final points = longestWorkout.route
                  .map((gp) => LatLng(gp.latitude, gp.longitude))
                  .toList();
              if (points.isNotEmpty) {
                firstPoint = points.first;
                polylines.add(
                  Polyline(
                    polylineId: const PolylineId('longest_route'),
                    points: points,
                    color: AppColors.buttonColor.withOpacity(0.8),
                    width: 4,
                  ),
                );
              }
            }

            if (firstPoint == null) {
              // Có workout nhưng ko có GPS route
              return Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Chưa có dữ liệu bản đồ cho các lộ trình này',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: firstPoint,
                    zoom: 200,
                  ),
                  polylines: polylines,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
