import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 80,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
          label: const Text('Bạn', style: TextStyle(color: Colors.black, fontSize: 16)),
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader('TÀI KHOẢN DOANDUONG0403@GMAIL.COM'),
          
          _buildSettingItem(
            icon: Icons.sensors,
            title: 'Kết nối ứng dụng hoặc thiết bị',
            subtitle: 'Tải trực tiếp lên Strava với hầu hết các ứng dụng hoặc thiết bị thể lực',
            onTap: () {},
          ),
          
          _buildSettingItem(
            title: 'Quản lý ứng dụng và thiết bị',
            onTap: () {},
          ),
          
          _buildSettingItem(
            title: 'Khôi phục các giao dịch mua hàng',
            onTap: () {},
          ),
          
          _buildSettingItem(
            title: 'Thay đổi email',
            onTap: () {},
          ),
          
          _buildSettingItem(
            title: 'Giúp đỡ',
            onTap: () {},
          ),

          _buildSectionHeader('TÙY CHỌN'),
          
          _buildSettingItem(
            title: 'Hình thức',
            trailing: _buildNewBadge(),
            onTap: () {},
          ),
          
          _buildSettingItem(
            title: 'Kiểm soát quyền riêng tư',
            trailing: _buildNewBadge(),
            onTap: () {},
          ),
          
          _buildSettingItem(
            title: 'Đơn vị đo lường',
            value: 'Kilomet',
            onTap: () {},
          ),
          
          _buildSettingItem(
            title: 'Nhiệt độ',
            value: 'Celsius',
            onTap: () {},
          ),
          
          _buildSettingItem(
            title: 'Hình ảnh nổi bật mặc định',
            subtitle: 'Chọn bản đồ hoặc hình ảnh đại diện cho các hoạt động bạn đã tải lên trong bảng tin.',
            value: 'Hình ảnh',
            onTap: () {},
          ),
          
          _buildSwitchItem(
            title: 'Tự động phát video',
            value: true,
            onChanged: (val) {},
          ),
          
          _buildSettingItem(title: 'Bản đồ mặc định'),
          _buildSettingItem(
            title: 'Thứ tự trên bảng tin',
            subtitle: 'Thay đổi cách sắp xếp các hoạt động trên bảng tin',
          ),
          _buildSettingItem(
            title: 'Vùng tập luyện',
            subtitle: 'Tùy chỉnh các vùng tập luyện của bạn',
          ),
          _buildSettingItem(title: 'Siri & Lối tắt'),
          _buildSettingItem(title: 'Beacon'),
          _buildSettingItem(title: 'Tích hợp đối tác'),
          _buildSettingItem(title: 'Thời tiết'),
          _buildSettingItem(title: 'Dữ liệu sức khỏe'),
          _buildSettingItem(title: 'Liên hệ'),
          _buildSettingItem(title: 'Thông báo đẩy'),
          _buildSettingItem(title: 'Thông báo qua email'),

          const SizedBox(height: 32),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Loginscreen()), (route) => false);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.buttonColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: AppColors.buttonColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildSettingItem({
    IconData? icon,
    required String title,
    String? subtitle,
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Colors.black, size: 28) : null,
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          if (trailing != null) trailing,
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: Colors.orange,
      ),
    );
  }

  Widget _buildNewBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'MỚI',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
