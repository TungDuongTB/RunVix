import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minHeight =
        MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight - 56), // Subtract AppBar height
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tham gia Runvix ngay',
                    style: TextStyle(
                      fontSize: 28,
                      color: AppColors.black,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // FULL NAME FIELD
                  _buildLabel('HỌ VÀ TÊN'),
                  const SizedBox(height: 8),
                  Inputcomponent(
                    hintText: 'Nhập họ và tên',
                    controller: _fullNameController,
                  ),
                  const SizedBox(height: 20),

                  // USERNAME FIELD
                  _buildLabel('USERNAME'),
                  const SizedBox(height: 8),
                  Inputcomponent(
                    hintText: 'Nhập username',
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 20),

                  // EMAIL FIELD
                  _buildLabel('EMAIL'),
                  const SizedBox(height: 8),
                  Inputcomponent(
                    hintText: 'Nhập email của bạn',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // PASSWORD FIELD
                  _buildLabel('MẬT KHẨU'),
                  const SizedBox(height: 8),
                  Inputcomponent(
                    hintText: 'Tạo mật khẩu',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                   // ADDRESS FIELD
                  _buildLabel('ĐỊA CHỈ (KHÔNG BẮT BUỘC)'),
                  const SizedBox(height: 8),
                  Inputcomponent(
                    hintText: 'Nhập địa chỉ',
                    controller: _addressController,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // REGISTER BUTTON
                  ButtonComponent(
                    text: 'ĐĂNG KÝ'.toUpperCase(),
                    width: double.infinity,
                    height: 52,
                    color: AppColors.buttonColor,
                    textColor: Colors.white,
                    borderWidth: 0,
                    borderRadius: 12,
                    textWeight: FontWeight.w700,
                    onPressed: () async {
                      final name = _fullNameController.text.trim();
                      final username = _usernameController.text.trim();
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      final address = _addressController.text.trim();

                      if (name.isNotEmpty && username.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                        final newUser = UserModel(
                          username: username,
                          email: email,
                          fullName: name,
                          address: address,
                          profilePicture: "https://picsum.photos/200", // Default
                        );
                        
                        await AuthenticationRepository.instance.registerWithEmailAndPassword(
                          newUser, 
                          password
                        );
                      } else {
                        Get.snackbar("Thông báo", "Vui lòng nhập đầy đủ thông tin bắt buộc", 
                          snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  const AuthTermsAgreement(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
        letterSpacing: 1.2,
      ),
    );
  }
}
