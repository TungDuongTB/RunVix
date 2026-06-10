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
    if (pickedFile != null) setState(() => _coverImage = pickedFile);
  }

  Future<void> _pickLogo() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _logoImage = pickedFile);
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
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
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
              GroupImageSelectors(
                coverImage: _coverImage,
                logoImage: _logoImage,
                onPickCover: _pickCover,
                onPickLogo: _pickLogo,
              ),
              const SizedBox(height: 24),

              GlassCard(
                borderRadius: 20.0,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin nhóm',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
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
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.buttonColor),
                        ),
                        Switch(
                          value: _hasRequirements,
                          activeColor: AppColors.buttonColor,
                          onChanged: (value) => setState(() => _hasRequirements = value),
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

              GlassCard(
                borderRadius: 20.0,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quyền tham gia',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PrivacyOptionCard(
                            title: 'Công khai',
                            subtitle: 'Ai cũng có thể tham gia',
                            isSelected: _isPublic,
                            icon: Icons.public,
                            onTap: () => setState(() => _isPublic = true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrivacyOptionCard(
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

              _buildCreateButton(),
              const SizedBox(height: 20),
            ],
          ),
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
          colors: [AppColors.primary, AppColors.buttonColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
