import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class AdminStatsPanel extends StatelessWidget {
  const AdminStatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context),
          const SizedBox(height: 32),
          const Text("Số liệu hoạt động cộng đồng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPerformanceChart(context),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRecentActivityTable(context)),
              const SizedBox(width: 24),
              if (Reponsive.isDesktop(context))
                SizedBox(width: 300, child: _buildActivityDistribution(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard("Tổng người dùng", "1,284", Icons.people, Colors.blue),
        _buildStatCard("Hoạt động tuần này", "+15%", Icons.trending_up, Colors.green),
        _buildStatCard("Thử thách đang chạy", "12", Icons.emoji_events, Colors.orange),
        _buildStatCard("Báo cáo vi phạm", "3", Icons.report_problem, Colors.red),
      ],
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

  Widget _buildPerformanceChart(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
              const Text("Thống kê theo Tuần/Tháng/Năm", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: "Tháng này",
                underline: const SizedBox(),
                items: ["Tuần này", "Tháng này", "Năm nay"].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (_) {},
              ),
            ],
          ),
          const Expanded(
            child: Center(
              child: Text("Biểu đồ tăng trưởng người dùng và hoạt động (Sử dụng fl_chart hoặc tương tự)", style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityTable(BuildContext context) {
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
          const Text("Phân công & Điều phối công việc", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text("Điều phối viên ${index + 1}"),
              subtitle: Text("Nhiệm vụ: Duyệt nội dung bài tập #$index"),
              trailing: const Chip(label: Text("Đang xử lý", style: TextStyle(fontSize: 10))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDistribution(BuildContext context) {
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
          const Text("Tỷ lệ hoạt động", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildDistItem("Chạy bộ", 0.7, Colors.blue),
          _buildDistItem("Đạp xe", 0.2, Colors.green),
          _buildDistItem("Đi bộ", 0.1, Colors.orange),
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
              Text(label, style: const TextStyle(fontSize: 12)),
              Text("${(percent * 100).toInt()}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: percent, color: color, backgroundColor: color.withOpacity(0.1), minHeight: 6),
        ],
      ),
    );
  }
}
