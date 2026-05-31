
import 'dart:math' as math;
import 'package:runvix/export.dart';

class AdminStatsPanel extends StatelessWidget {
  const AdminStatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final stats = controller.stats.value;
      if (stats == null) {
        return const Center(child: Text("Không có dữ liệu"));
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchAdminStats(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(context, stats),
              const SizedBox(height: 32),
              const Text(
                "Số liệu hoạt động cộng đồng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              _buildPerformanceChart(context, stats),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Reponsive.isDesktop(context)) ...[
                    const SizedBox(width: 24),
                    Expanded(child: _buildActivityDistribution(context, stats)),
                  ],
                ],
              ),
              if (!Reponsive.isDesktop(context)) ...[
                const SizedBox(height: 24),
                _buildActivityDistribution(context, stats),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCards(BuildContext context, stats) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildStatCard("Tổng người dùng", stats.totalUsers.toString(), Icons.people, Colors.blue),
          const SizedBox(width: 16),
          _buildStatCard("Hoạt động tuần này", stats.activityGrowth, Icons.trending_up, Colors.green),
          const SizedBox(width: 16),
          _buildStatCard("Thử thách đang chạy", stats.activeChallenges.toString(), Icons.emoji_events, Colors.orange),
          const SizedBox(width: 16),
          _buildStatCard("Báo cáo vi phạm", stats.violationReports.toString(), Icons.report_problem, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context, stats) {
    // Tìm giá trị lớn nhất để làm mốc 100% chiều cao
    double maxValue = 0;
    for (var d in stats.performanceData) {
      if ((d.value as num).toDouble() > maxValue) maxValue = (d.value as num).toDouble();
    }
    if (maxValue == 0) maxValue = 1.0;

    return Container(
      height: 350,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  "Thống kê hiệu suất tuần",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: "Tháng này",
                style: const TextStyle(fontSize: 13, color: Colors.black),
                underline: const SizedBox(),
                items: ["Tuần này", "Tháng này", "Năm nay"].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Đảm bảo availableHeight không âm
                final availableHeight = (constraints.maxHeight - 25).clamp(0.0, constraints.maxHeight);
                
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: stats.performanceData.map<Widget>((data) {
                        final barHeight = ((data.value as num).toDouble() / maxValue) * availableHeight;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: Reponsive.isMobile(context) ? 15 : 25,
                                height: barHeight.clamp(4.0, availableHeight),
                                decoration: BoxDecoration(
                                  color: AppColors.buttonColor.withOpacity(0.8),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data.label,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDistribution(BuildContext context, stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tỷ lệ hoạt động",
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = math.min(constraints.maxWidth, constraints.maxHeight);
                      return Center(
                        child: SizedBox(
                          width: size,
                          height: size,
                          child: CustomPaint(
                            painter: PieChartPainter(
                              data: stats.activityDistribution,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: stats.activityDistribution.entries.map<Widget>((entry) {
                      Color color = entry.key == "Chạy bộ" ? Colors.blue : (entry.key == "Đạp xe" ? Colors.green : Colors.orange);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${entry.key}: ${(entry.value * 100).toInt()}%",
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...stats.activityDistribution.entries.map((entry) {
            Color color = entry.key == "Chạy bộ" ? Colors.blue : (entry.key == "Đạp xe" ? Colors.green : Colors.orange);
            return _buildDistItem(entry.key, entry.value, color);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDistItem(String label, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${(percent * 100).toInt()}%",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            color: color,
            backgroundColor: color.withOpacity(0.1),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;

  PieChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -math.pi / 2;

    final entries = data.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final sweepAngle = entry.value * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = _getColor(entry.key);

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    // Draw white circle in middle to make it a donut chart (optional)
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.25, Paint()..color = Colors.white);
  }

  Color _getColor(String label) {
    if (label == "Chạy bộ") return Colors.blue;
    if (label == "Đạp xe") return Colors.green;
    return Colors.orange;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
