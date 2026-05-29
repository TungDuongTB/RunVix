import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class MapSegmentDetailCard extends StatelessWidget {
  const MapSegmentDetailCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StravaController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(() => Text(
                      controller.selectedSegment.value?['name'] ?? 'Không tên',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
              IconButton(
                onPressed: () => controller.selectedSegment.value = null,
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Thông tin segment
          Obx(() => Row(
                children: [
                  _buildInfoItem(
                    Icons.straighten,
                    '${((controller.selectedSegment.value?['distance'] ?? 0) / 1000).toStringAsFixed(2)} km',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    Icons.trending_up,
                    '${controller.selectedSegment.value?['average_grade'] ?? 0}%',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    Icons.landscape,
                    '${controller.selectedSegment.value?['elev_difference'] ?? 0}m',
                  ),
                ],
              )),

          const Divider(height: 24),

          const Text(
            "Bảng xếp hạng (Top 3)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // Leaderboard
          Obx(() {
            if (controller.isLoadingDetail.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.selectedSegmentLeaderboard.isEmpty) {
              return const Text("Chưa có dữ liệu xếp hạng.");
            }
            return Column(
              children: controller.selectedSegmentLeaderboard
                  .take(3)
                  .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text(
                              "#${entry['rank']}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(entry['athlete_name'] ?? 'Ẩn danh'),
                            ),
                            Text(
                              _formatDuration(entry['elapsed_time'] ?? 0),
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[800])),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
