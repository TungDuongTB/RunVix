import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class AddManualActivityScreen extends StatelessWidget {
  const AddManualActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Hủy',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        title: const Text(
          'Thêm hoạt động',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            _buildTextField(hintText: 'Chạy bộ buổi chiều'),
            const SizedBox(height: 16),
            
            // Description Input
            _buildTextField(
              hintText: 'Thế nào rồi? Hãy chia sẻ thêm về hoạt động của bạn và sử dụng @ để gắn thẻ ai đó.',
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            
            // Activity Type Dropdown
            _buildDropdownField(
              icon: Icons.directions_run,
              label: 'Chạy bộ',
            ),
            const SizedBox(height: 16),
            
            // Add Photo/Video
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_outlined, size: 40, color: Colors.black54),
                  const SizedBox(height: 8),
                  const Text(
                    'Thêm ảnh/video',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Stats Section
            const Text(
              'Thống kê hoạt động',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildDropdownField(
              icon: Icons.calendar_today_outlined,
              label: '17:48 Hôm nay',
            ),
            const SizedBox(height: 16),
            
            _buildDropdownField(
              icon: Icons.access_time,
              label: '00:00:00',
            ),
            const SizedBox(height: 16),
            
            _buildDropdownField(
              icon: Icons.location_on_outlined,
              label: '0.00 km',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor.withOpacity(0.5), // Lighter orange as in image
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Lưu hoạt động',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String hintText, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDropdownField({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }
}
