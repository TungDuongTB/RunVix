import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

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
            // Nút chọn loại hoạt động
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.buttonColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_run, size: 18, color: AppColors.buttonColor),
                    const SizedBox(width: 8),
                    const Text('Chạy bộ', style: TextStyle(color: AppColors.buttonColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Phần Tuần này
            _buildThisWeekSection(controller),
            
            const Divider(height: 40, thickness: 8, color: Color(0xFFF2F2F2)),
            
            // Phần Thống kê tổng quát
            _buildOverallStatsSection(controller),
            
            const SizedBox(height: 100), // Khoảng cách cuối trang
          ],
        )),
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
              _buildStatItem('Tổng quãng đường', '${(controller.totalDistance.value / 1000).toStringAsFixed(2)} km'),
              _buildStatItem('Số buổi tập', '${controller.workoutCount.value}'),
              _buildStatItem('Thời gian', '${(controller.totalDuration.value / 60).toStringAsFixed(0)} phút'),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Tiến trình', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          // Biểu đồ đơn giản
          Container(
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
          )
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
          const Text('Thành tích cá nhân', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildStatRow(Icons.emoji_events_outlined, "Quãng đường dài nhất", "0.0 km"),
          const SizedBox(height: 12),
          _buildStatRow(Icons.speed, "Nhịp độ nhanh nhất", "-:-- /km"),
          const SizedBox(height: 12),
          _buildStatRow(Icons.timer_outlined, "Thời gian lâu nhất", "00:00:00"),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 24),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, {CrossAxisAlignment crossAxis = CrossAxisAlignment.center}) {
    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
