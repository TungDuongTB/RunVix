import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool _hasRequirements = false;
  final _paceController = TextEditingController();
  final _minKmController = TextEditingController();
  final _minSessionsController = TextEditingController();
  
  bool _isPublic = true;
  XFile? _coverImage;
  XFile? _logoImage;
  final _picker = ImagePicker();

  Future<void> _pickCover() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = pickedFile;
      });
    }
  }

  Future<void> _pickLogo() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoImage = pickedFile;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _paceController.dispose();
    _minKmController.dispose();
    _minSessionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.4),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Tạo Nhóm Mới',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomPaint(
        painter: RadialGradientPainter(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover & Logo Picker Container
              _buildImageSelectors(),
              const SizedBox(height: 24),

              // Form fields bọc trong GlassCard
              GlassCard(
                borderRadius: 20.0,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Thông tin nhóm'),
                    const SizedBox(height: 16),
                    FocusableTextField(
                      controller: _nameController,
                      label: 'Tên nhóm',
                      hint: 'Nhập tên nhóm chạy...',
                      icon: Icons.group_outlined,
                    ),
                    const SizedBox(height: 16),
                    FocusableTextField(
                      controller: _descriptionController,
                      label: 'Mô tả',
                      hint: 'Mục tiêu, lịch tập luyện của nhóm...',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ĐIỀU KIỆN THAM GIA',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.buttonColor,
                          ),
                        ),
                        Switch(
                          value: _hasRequirements,
                          activeColor: AppColors.buttonColor,
                          onChanged: (value) {
                            setState(() {
                              _hasRequirements = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_hasRequirements) ...[
                      const SizedBox(height: 12),
                      FocusableTextField(
                        controller: _paceController,
                        label: 'Yêu cầu Pace tối thiểu',
                        hint: 'Ví dụ: Đã hoàn thành ít nhất 1 giải FM...',
                        icon: Icons.speed_outlined,
                      ),
                      const SizedBox(height: 16),
                      FocusableTextField(
                        controller: _minKmController,
                        label: 'SỐ KM TỐI THIỂU ĐÃ CHẠY',
                        hint: 'Ví dụ: 100km/tháng',
                        icon: Icons.directions_run_outlined,
                      ),
                      const SizedBox(height: 16),
                      FocusableTextField(
                        controller: _minSessionsController,
                        label: 'SỐ BUỔI TỐI THIỂU',
                        hint: 'Ví dụ: 3 buổi/tuần',
                        icon: Icons.calendar_month_outlined,
                      ),
                    ],
                    const SizedBox(height: 16),
                    FocusableTextField(
                      controller: _locationController,
                      label: 'Địa điểm chính',
                      hint: 'Ví dụ: Hồ Tây, Hà Nội...',
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quyền riêng tư
              GlassCard(
                borderRadius: 20.0,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Quyền tham gia'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPrivacyOption(
                            title: 'Công khai',
                            subtitle: 'Ai cũng có thể tham gia',
                            isSelected: _isPublic,
                            icon: Icons.public,
                            onTap: () => setState(() => _isPublic = true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPrivacyOption(
                            title: 'Riêng tư',
                            subtitle: 'Cần duyệt thành viên',
                            isSelected: !_isPublic,
                            icon: Icons.lock_outline,
                            onTap: () => setState(() => _isPublic = false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Nút Tạo nhóm
              _buildCreateButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildImageSelectors() {
    return Stack(
      children: [
        // Cover Photo Picker
        GestureDetector(
          onTap: _pickCover,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.buttonColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              image: _coverImage != null
                  ? DecorationImage(
                      image: FileImage(File(_coverImage!.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _coverImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade600, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Tải lên ảnh bìa nhóm',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black45,
                        radius: 14,
                        child: Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
          ),
        ),

        // Logo Picker
        Positioned(
          left: 20,
          bottom: 10,
          child: GestureDetector(
            onTap: _pickLogo,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.white, width: 3.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
                image: _logoImage != null
                    ? DecorationImage(
                        image: FileImage(File(_logoImage!.path)),
                        fit: BoxFit.cover,
                    )
                    : null,
              ),
              child: _logoImage == null
                  ? Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600, size: 24)
                  : const Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        backgroundColor: AppColors.buttonColor,
                        radius: 10,
                        child: Icon(Icons.edit, color: Colors.white, size: 10),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.buttonColor.withOpacity(0.08)
              : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.buttonColor
                : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.buttonColor : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.buttonColor : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.buttonColor.withOpacity(0.8) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.buttonColor,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (_nameController.text.trim().isEmpty) {
              Get.snackbar("Thông báo", "Vui lòng nhập tên nhóm");
              return;
            }
            Get.back();
            Get.snackbar(
              "Thành công",
              "Đã tạo nhóm '${_nameController.text.trim()}' thành công!",
              backgroundColor: Colors.white.withOpacity(0.8),
              colorText: Colors.black87,
            );
          },
          child: const Center(
            child: Text(
              'Tạo Nhóm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
