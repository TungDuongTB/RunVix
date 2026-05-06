import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class RecordAdvancedSettings extends StatelessWidget {
  const RecordAdvancedSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSettingRow(Icons.sensors, 'Chia sẻ vị trí trực tiếp', 'Tắt'),
          const Divider(height: 32),
          _buildSettingRow(
              Icons.refresh, 'Theo dõi vòng', 'Tự theo dõi vòng của bạn',
              isSwitch: true),
          const Divider(height: 32),
          _buildSettingRow(Icons.favorite_border, 'Thêm cảm biến', ''),
          const Divider(height: 32),
          _buildSettingRow(Icons.settings_outlined, 'Cài đặt',
              'Tín hiệu âm thanh, tự động dừng...'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String title, String subtitle,
      {bool isSwitch = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
            if (subtitle.isNotEmpty) Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
        if (isSwitch) Switch(value: false,
            onChanged: (v) {},
            activeColor: AppColors.buttonColor) else
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ],
    );
  }
}
