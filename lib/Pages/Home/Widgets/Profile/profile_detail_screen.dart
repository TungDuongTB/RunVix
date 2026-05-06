import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.ios_share, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Profile Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://picsum.photos/200'),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Dương Đoàn', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Hanoi, Vietnam', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            // Followers Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFollowStat('Đang theo dõi', '0'),
                  const SizedBox(width: 40),
                  _buildFollowStat('Người theo dõi', '0'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Buttons: QR & Edit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.buttonColor,
                        side: BorderSide(color: AppColors.buttonColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: const Text('Chia sẻ mã QR của tôi', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.buttonColor,
                        side: BorderSide(color: AppColors.buttonColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Chỉnh sửa', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 40, thickness: 1, color: Color(0xFFF2F2F2)),

            // Stats Section: Tuần này
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.directions_run, size: 20),
                      SizedBox(width: 8),
                      Text('Tuần này', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('Quãng đường', '0.00 km'),
                      _buildMiniStat('Thời gian', '0 giờ'),
                      _buildMiniStat('Độ cao', '0 m'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLineChartMockup(),
                ],
              ),
            ),

            const Divider(height: 40, thickness: 1, color: Color(0xFFF2F2F2)),

            // List Options
            _buildListOption(Icons.grid_view, 'Hoạt động'),
            _buildListOption(Icons.bar_chart, 'Số liệu thống kê'),
            _buildListOption(Icons.route_outlined, 'Lộ trình'),
            _buildListOption(Icons.location_on_outlined, 'Đoạn'),
            _buildListOption(Icons.emoji_events_outlined, 'Thành tích tốt nhất', subtitle: 'Xem tất cả'),
            _buildListOption(Icons.article_outlined, 'Bài đăng'),
            _buildListOption(Icons.directions_bike_outlined, 'Thiết bị'),

            const Divider(height: 40, thickness: 8, color: Color(0xFFF2F2F2)),

            // Section: Tủ trưng bày thành tích
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tủ trưng bày thành tích', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAchievementIcon('Hoạt động\nđầu tiên'),
                      _buildAchievementIcon('Hoạt động\nthứ 3'),
                      _buildAchievementIcon('Hoạt động\nthứ 5'),
                      _buildAchievementIcon('Hoạt động\nthứ 10'),
                    ],
                  ),
                ],
              ),
            ),
            
            _buildListOption(null, 'Tất cả cúp thành tích', isSmall: true),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowStat(String label, String count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLineChartMockup() {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: Stack(
            children: [
              Positioned(right: 0, child: const Text('0.00 km', style: TextStyle(fontSize: 10, color: Colors.grey))),
              Positioned(bottom: 20, right: 0, child: const Text('0.00 km', style: TextStyle(fontSize: 10, color: Colors.grey))),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(height: 1, color: Colors.grey.shade300),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(12, (index) => Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(width: 1, height: 80, color: Colors.grey.shade100),
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == 11 ? AppColors.buttonColor : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.buttonColor, width: 2),
                      ),
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text('THÁNG 2', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('THÁNG 3', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('THÁNG 4', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        )
      ],
    );
  }

  Widget _buildListOption(IconData? icon, String title, {String subtitle = '—', bool isSmall = false}) {
    return ListTile(
      leading: icon != null ? Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.black87, size: 24),
      ) : null,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmall ? 15 : 16)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildAchievementIcon(String label) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Center(
            child: Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2),
        ),
      ],
    );
  }
}
