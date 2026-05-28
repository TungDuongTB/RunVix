import 'package:flutter/material.dart';
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
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildActivitySelector(),
            const SizedBox(height: 24),
            _buildThisWeekSection(controller),
            const Divider(height: 40, thickness: 8, color: Color(0xFFF2F2F2)),
            _buildOverallStatsSection(controller),
            const SizedBox(height: 100),
          ],
        )),
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
            Text('Chạy bộ', style: TextStyle(color: AppColors.buttonColor, fontWeight: FontWeight.bold)),
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
          const Text('Hoạt động gần đây', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatItem(label: 'Tổng quãng đường', value: '${(controller.totalDistance.value / 1000).toStringAsFixed(2)} km'),
              StatItem(label: 'Số buổi tập', value: '${controller.workoutCount.value}'),
              StatItem(label: 'Thời gian', value: '${(controller.totalDuration.value / 60).toStringAsFixed(0)} phút'),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Tiến trình', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          _buildSimpleChart(controller),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(ProfileController controller) {
    return Container(
      height: 100,
      alignment: Alignment.bottomLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          return Container(
            width: 20,
            height: controller.workoutCount.value > 0 ? 10.0 + (index % 3 * 20) : 5,
            decoration: BoxDecoration(
              color: AppColors.buttonColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOverallStatsSection(ProfileController controller) {
    return const Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thành tích cá nhân', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          StatRow(icon: Icons.emoji_events_outlined, title: "Quãng đường dài nhất", value: "0.0 km"),
          SizedBox(height: 12),
          StatRow(icon: Icons.speed, title: "Nhịp độ nhanh nhất", value: "-:-- /km"),
          SizedBox(height: 12),
          StatRow(icon: Icons.timer_outlined, title: "Thời gian lâu nhất", value: "00:00:00"),
        ],
      ),
    );
  }
}
