import 'dart:io';
import 'dart:ui';
import 'package:runvix/export.dart';

class CreateGroupEventScreen extends StatefulWidget {
  final GroupModel group;

  const CreateGroupEventScreen({super.key, required this.group});

  @override
  State<CreateGroupEventScreen> createState() => _CreateGroupEventScreenState();
}

class _CreateGroupEventScreenState extends State<CreateGroupEventScreen> {
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  XFile? _coverImage;
  final _picker = ImagePicker();

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

    GroupController.instance.createGroupEvent(
      group: widget.group,
      title: title,
      eventDate: _selectedDate,
      time: _timeController.text.trim(),
      imageFile: _coverImage,
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
          'Thêm sự kiện',
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
                ],
              ),
            ),
            const SizedBox(height: 32),
            Obx(() {
              final loading = GroupController.instance.isLoading.value;
              return SizedBox(
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
                          'Tạo sự kiện',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
