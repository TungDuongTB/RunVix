import 'dart:io';
import 'dart:ui';
import 'package:runvix/export.dart';

class EditGroupEventScreen extends StatefulWidget {
  final GroupModel group;
  final ChallengeModel challenge;

  const EditGroupEventScreen({super.key, required this.group, required this.challenge});

  @override
  State<EditGroupEventScreen> createState() => _EditGroupEventScreenState();
}

class _EditGroupEventScreenState extends State<EditGroupEventScreen> {
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  XFile? _coverImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.challenge.title;
    _selectedDate = widget.challenge.startDate;
    final hour = _selectedDate.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    _timeController.text = '${hour12.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      _timeController.text =
          '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';
      setState(() {});
    }
  }

  Future<void> _pickCover() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _coverImage = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập tên sự kiện.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    DateTime combinedStartDate = _selectedDate;
    if (_timeController.text.isNotEmpty) {
      try {
        final timeString = _timeController.text; // Format: "05:00 AM"
        final isPM = timeString.contains('PM');
        final parts = timeString.split(RegExp(r'[: ]'));
        int hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (isPM && hour != 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;
        combinedStartDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour, minute);
      } catch (_) {}
    }

    ChallengeController.instance.updateChallenge(
      challenge: widget.challenge,
      title: title,
      description: widget.challenge.description,
      startDate: combinedStartDate,
      endDate: combinedStartDate.add(const Duration(days: 30)), 
      imageFile: _coverImage,
    );
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa sự kiện này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (widget.challenge.id != null) {
                ChallengeController.instance.deleteChallenge(widget.challenge.id!);
                Get.back(); // Quay lại màn hình nhóm
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.4),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Chỉnh sửa sự kiện',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhóm: ${widget.group.name}',
              style: const TextStyle(
                color: AppColors.buttonColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin sự kiện',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  FocusableTextField(
                    controller: _titleController,
                    label: 'Tên sự kiện',
                    hint: 'Ví dụ: Chạy bán đảo Sơn Trà',
                    icon: Icons.event_outlined,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: FocusableTextField(
                        controller: TextEditingController(text: dateLabel),
                        label: 'Ngày diễn ra',
                        hint: 'Chọn ngày',
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickTime,
                    child: AbsorbPointer(
                      child: FocusableTextField(
                        controller: _timeController,
                        label: 'Thời gian',
                        hint: 'Ví dụ: 05:00 AM',
                        icon: Icons.schedule_outlined,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ảnh bìa (tuỳ chọn)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickCover,
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        image: _coverImage != null
                            ? DecorationImage(
                                image: FileImage(File(_coverImage!.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _coverImage == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 36, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Chọn ảnh sự kiện',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            )
                          : null,
                    ),
                  ),
                  if (widget.challenge.imageUrl.isNotEmpty && _coverImage == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Sự kiện đang dùng ảnh hiện tại', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    )
                ],
              ),
            ),
            const SizedBox(height: 32),
            Obx(() {
              final loading = ChallengeController.instance.isLoading.value;
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Lưu thay đổi',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: loading ? null : _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xóa sự kiện',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
