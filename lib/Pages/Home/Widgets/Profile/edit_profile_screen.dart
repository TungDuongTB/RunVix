import 'package:flutter/material.dart';
import 'package:runvix/export.dart';
import 'package:intl/intl.dart';

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.buttonColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
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
          TextButton(
            onPressed: () {
              final updatedUser = controller.user.value.copyWith(
                firstName: firstNameController.text.trim(),
                lastName: lastNameController.text.trim(),
                fullName: "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
                bio: bioController.text.trim(),
                city: cityController.text.trim(),
                mainSport: selectedSport,
                gender: selectedGender,
                dob: selectedDate,
                weight: double.tryParse(weightController.text) ?? 0.0,
                height: double.tryParse(heightController.text) ?? 0.0,
              );
              controller.updateUserSettings(updatedUser);
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Name Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(controller.user.value.profilePicture),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: firstNameController,
                          decoration: const InputDecoration(
                            hintText: 'Tên',
                            border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E5E5))),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E5E5))),
                          ),
                        ),
                        TextField(
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            hintText: 'Họ',
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Bio & City
            _buildSection([
              _buildTextField('Tiểu sử', bioController, hint: 'Thêm tiểu sử'),
              const Divider(height: 1, indent: 16),
              _buildTextField('Thành phố', cityController, hint: 'Ví dụ: Hà Nội'),
            ]),
            const SizedBox(height: 20),
            // Main Sport
            _buildSection([
              _buildPickerRow('Môn thể thao chính', selectedSport, () {
                _showSportPicker();
              }),
            ]),
            const SizedBox(height: 30),
            // Section Header
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('THÔNG TIN VỀ VẬN ĐỘNG VIÊN', 
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
            // Athlete Info
            _buildSection([
              _buildPickerRow('Chọn ngày sinh', 
                selectedDate != null ? DateFormat('ngày d thg M, yyyy').format(selectedDate!) : 'Chọn ngày sinh', 
                () => _selectDate(context)),
              const Divider(height: 1, indent: 16),
              _buildPickerRow('Giới tính', selectedGender, () {
                _showGenderPicker();
              }),
              const Divider(height: 1, indent: 16),
              _buildTextField('Trọng lượng (kg)', weightController, suffix: 'kg', keyboardType: TextInputType.number),
              const Divider(height: 1, indent: 16),
              _buildTextField('Chiều cao (cm)', heightController, suffix: 'cm', keyboardType: TextInputType.number),
            ]),
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

  Widget _buildSection(List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(children: children),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, String? suffix, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                suffixText: suffix != null ? " $suffix" : null,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerRow(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  void _showSportPicker() {
    final sports = ['Chạy bộ', 'Đạp xe', 'Bơi lội', 'Đi bộ', 'Khác'];
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: sports.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(sports[index]),
            onTap: () {
              setState(() => selectedSport = sports[index]);
              Get.back();
            },
          ),
        ),
      ),
    );
  }

  void _showGenderPicker() {
    final genders = ['Nam', 'Nữ', 'Khác'];
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: genders.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(genders[index]),
            onTap: () {
              setState(() => selectedGender = genders[index]);
              Get.back();
            },
          ),
        ),
      ),
    );
  }
}
