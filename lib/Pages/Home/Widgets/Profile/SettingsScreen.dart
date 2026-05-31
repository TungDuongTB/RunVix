import 'package:runvix/export.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  final userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    var user = userController.user.value;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 80,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
          label: const Text('Bạn', style: TextStyle(color: Colors.black, fontSize: 14)),
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
          _buildSectionHeader(user.email.isEmpty ? 'Tài khoản' : user.email),

          _buildSettingItem(
            title: 'Quản lý ứng dụng và thiết bị',
            onTap: () {},
          ),
          
          _buildSettingItem(
            title: 'Thay đổi email',
            onTap: () {},
          ),
          
          _buildSettingItem(
            title: 'Đổi mật khẩu',
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

          _buildSettingItem(title: 'Bản đồ mặc định'),

          const SizedBox(height: 32),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton(
              onPressed: () => AuthenticationRepository.instance.logout(),
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
        activeTrackColor: Colors.lightBlueAccent,
      ),
    );
  }

  Widget _buildNewBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'MỚI',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
