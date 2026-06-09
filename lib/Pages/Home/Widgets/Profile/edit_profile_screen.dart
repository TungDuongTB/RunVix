import 'package:runvix/export.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../../../../Component/ProfileInputComponent.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final controller = UserController.instance;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController bioController;
  late TextEditingController cityController;
  late TextEditingController weightController;
  late TextEditingController heightController;

  String selectedSport = 'Chạy bộ';
  String selectedGender = 'Nam';
  DateTime? selectedDate;
  
  XFile? selectedImage;
  Uint8List? imageBytes;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = controller.user.value;
    firstNameController = TextEditingController(text: user.firstName);
    lastNameController = TextEditingController(text: user.lastName);
    bioController = TextEditingController(text: user.bio);
    cityController = TextEditingController(text: user.city);
    weightController = TextEditingController(text: user.weight > 0 ? user.weight.toString() : '');
    heightController = TextEditingController(text: user.height > 0 ? user.height.toString() : '');
    selectedSport = user.mainSport;
    selectedGender = user.gender;
    selectedDate = user.dob;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    bioController.dispose();
    cityController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => isSaving = true);
    try {
      String imageUrl = controller.user.value.profilePicture;
      if (selectedImage != null) {
        imageUrl = await controller.uploadImage(selectedImage!);
      }

      final updatedUser = controller.user.value.copyWith(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        fullName: "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
        bio: bioController.text.trim(),
        city: cityController.text.trim(),
        profilePicture: imageUrl,
        mainSport: selectedSport,
        gender: selectedGender,
        dob: selectedDate,
        weight: double.tryParse(weightController.text) ?? 0.0,
        height: double.tryParse(heightController.text) ?? 0.0,
      );
      await controller.updateUserSettings(updatedUser);
    } catch (e) {
      Get.snackbar("Lỗi", "Đã xảy ra lỗi: $e");
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAvatarAndNameSection(),
            const SizedBox(height: 20),
            ProfileSection(children: [
              ProfileTextField(label: 'Tiểu sử', controller: bioController, hint: 'Thêm tiểu sử'),
              ProfileTextField(label: 'Thành phố', controller: cityController, hint: 'Ví dụ: Hà Nội', isLast: true),
            ]),
            const SizedBox(height: 20),
            ProfileSection(children: [
              ProfilePickerRow(label: 'Môn thể thao chính', value: selectedSport, onTap: _showSportPicker, isLast: true),
            ]),
            ProfileSection(
              title: 'THÔNG TIN VỀ VẬN ĐỘNG VIÊN',
              children: [
                ProfilePickerRow(
                  label: 'Chọn ngày sinh', 
                  value: selectedDate != null ? DateFormat('d/M/yyyy').format(selectedDate!) : 'Chọn ngày sinh',
                  onTap: () => _selectDate(context)
                ),
                ProfilePickerRow(label: 'Giới tính', value: selectedGender, onTap: _showGenderPicker),
                ProfileTextField(label: 'Trọng lượng (kg)', controller: weightController, suffix: 'kg', keyboardType: TextInputType.number),
                ProfileTextField(label: 'Chiều cao (cm)', controller: heightController, suffix: 'cm', keyboardType: TextInputType.number, isLast: true),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Dùng để tính toán calo, thể lực và nhiều thông số khác.',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leadingWidth: 80,
      leading: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Hủy', style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
      title: const Text('Hồ sơ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        Obx(() => TextButton(
          onPressed: (controller.isLoading.value || controller.imageUploading.value || isSaving) ? null : _handleSave,
          child: (controller.isLoading.value || controller.imageUploading.value || isSaving)
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
            : const Text('Lưu', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        )),
      ],
    );
  }

  Widget _buildAvatarAndNameSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: imageBytes != null 
                    ? MemoryImage(imageBytes!)
                    : NetworkImage(controller.user.value.profilePicture) as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.buttonColor, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    hintText: 'Tên',
                    border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.dividerGrey)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.dividerGrey)),
                  ),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(hintText: 'Họ', border: InputBorder.none),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods (Pickers)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.buttonColor)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() { selectedImage = image; imageBytes = bytes; });
    }
  }

  void _showSportPicker() {
    _showGenericPicker(['Chạy bộ', 'Đạp xe', 'Bơi lội', 'Đi bộ', 'Khác'], (val) => setState(() => selectedSport = val));
  }

  void _showGenderPicker() {
    _showGenericPicker(['Nam', 'Nữ', 'Khác'], (val) => setState(() => selectedGender = val));
  }

  void _showGenericPicker(List<String> items, Function(String) onSelected) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(items[index]),
            onTap: () { onSelected(items[index]); Get.back(); },
          ),
        ),
      ),
    );
  }
}
