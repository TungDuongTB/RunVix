import 'dart:io';
import 'package:flutter/material.dart';
import 'package:runvix/export.dart';
import 'package:intl/intl.dart' as intl;

class AddManualActivityScreen extends StatelessWidget {
  const AddManualActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManualActivityController());

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
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            _buildTextField(
              hintText: 'Chạy bộ buổi chiều',
              controller: controller.title,
            ),
            const SizedBox(height: 16),

            // Description Input
            _buildTextField(
              hintText: 'Thế nào rồi? Hãy chia sẻ thêm về hoạt động của bạn...',
              maxLines: 4,
              controller: controller.description,
            ),
            const SizedBox(height: 16),

            // Activity Type Dropdown (Mock for now, can be expanded)
            _buildDropdownField(
              icon: Icons.directions_run,
              label: controller.selectedType.value,
            ),
            const SizedBox(height: 16),

            // Add Photo/Video
            GestureDetector(
              onTap: () => controller.pickImage(),
              child: Obx(
                () => Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: controller.selectedImage.value != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GetPlatform.isWeb
                              ? Image.network(
                                  controller.selectedImage.value!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(controller.selectedImage.value!.path),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: Colors.black54,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Thêm ảnh/video',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Stats Section
            const Text(
              'Thống kê hoạt động',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => controller.selectDateTime(context),
              child: Obx(
                () => _buildDropdownField(
                  icon: Icons.calendar_today_outlined,
                  label: intl.DateFormat(
                    'HH:mm dd/MM/yyyy',
                  ).format(controller.selectedDateTime.value),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Duration Picker (Simplified for UI)
            _buildStatInput(
              icon: Icons.access_time,
              label: 'Thời gian (Giờ : Phút : Giây)',
              child: Row(
                children: [
                  _buildNumberInput(
                    onChanged: (v) =>
                        controller.hours.value = int.tryParse(v) ?? 0,
                    hint: '00',
                  ),
                  const Text(' : '),
                  _buildNumberInput(
                    onChanged: (v) =>
                        controller.minutes.value = int.tryParse(v) ?? 0,
                    hint: '00',
                  ),
                  const Text(' : '),
                  _buildNumberInput(
                    onChanged: (v) =>
                        controller.seconds.value = int.tryParse(v) ?? 0,
                    hint: '00',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Distance Input
            _buildStatInput(
              icon: Icons.location_on_outlined,
              label: 'Khoảng cách (km)',
              child: TextField(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) =>
                    controller.distance.value = double.tryParse(v) ?? 0.0,
                decoration: const InputDecoration(
                  hintText: '0.00',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Toggle "Public/Post to Feed"
            Obx(
              () => SwitchListTile(
                title: const Text(
                  'Chia sẻ lên bảng tin',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Hoạt động này sẽ hiển thị với mọi người'),
                value: controller.isPublic.value,
                onChanged: (value) => controller.isPublic.value = value,
                activeColor: AppColors.buttonColor,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.saveActivity(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Lưu hoạt động',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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

  Widget _buildStatInput({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput({
    required Function(String) onChanged,
    required String hint,
  }) {
    return SizedBox(
      width: 40,
      child: TextField(
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}
