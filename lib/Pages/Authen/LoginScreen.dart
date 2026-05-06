import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Đăng nhập vào Runvix',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      color: AppColors.black,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
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
                    hintText: 'Nhập mật khẩu',
                    controller: _passwordController,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // LOGIN BUTTON
                  ButtonComponent(
                    text: 'Đăng nhập'.toUpperCase(),
                    width: double.infinity,
                    height: 52,
                    color: AppColors.buttonColor,
                    textColor: Colors.white,
                    borderWidth: 0,
                    borderRadius: 12,
                    textWeight: FontWeight.w700,
                    onPressed: () {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      if (email.isNotEmpty && password.isNotEmpty) {
                      } else {
                        Get.snackbar("Thông báo", "Vui lòng nhập đầy đủ email và mật khẩu", 
                          snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  const DividerWithCenter(centerText: 'Hoặc'),
                  const SizedBox(height: 16),
                  const AuthSocialButtons(),
                  const SizedBox(height: 24),
                  
                  // Chuyển sang Đăng ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản? "),
                      GestureDetector(
                        onTap: () => Get.to(() => const Signin()),
                        child: const Text(
                          "Đăng ký ngay",
                          style: TextStyle(color: AppColors.buttonColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
