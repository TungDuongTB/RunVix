import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Đăng ký',
                  style: TextStyle(
                    fontSize: 28,
                    color: AppColors.black,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildLabel('HỌ VÀ TÊN'),
                const SizedBox(height: 8),
                Inputcomponent(
                  hintText: 'Nhập họ và tên',
                  controller: _fullNameController,
                ),
                const SizedBox(height: 20),

                _buildLabel('USERNAME'),
                const SizedBox(height: 8),
                Inputcomponent(
                  hintText: 'Nhập username',
                  controller: _usernameController,
                ),
                const SizedBox(height: 20),

                _buildLabel('EMAIL'),
                const SizedBox(height: 8),
                Inputcomponent(
                  hintText: 'Nhập email của bạn',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _buildLabel('MẬT KHẨU'),
                const SizedBox(height: 8),
                Inputcomponent(
                  hintText: 'Tạo mật khẩu',
                  controller: _passwordController,
                  obscureText: true,
                ),
                
                const SizedBox(height: 32),
                
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

                    if (name.isNotEmpty && username.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                      final newUser = UserModel(
                        username: username,
                        email: email,
                        fullName: name,
                        address: "",
                        profilePicture: "https://picsum.photos/200",
                      );
                      
                      await AuthenticationRepository.instance.registerWithEmailAndPassword(
                        newUser, 
                        password
                      );
                    } else {
                      Get.snackbar("Thông báo", "Vui lòng nhập đầy đủ thông tin", 
                        snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                ),
                
                const SizedBox(height: 24),
                const DividerWithCenter(centerText: 'Hoặc'),
                const SizedBox(height: 24),
                const AuthSocialButtons(),
                
                const SizedBox(height: 32),
                const AuthTermsAgreement(),
              ],
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
