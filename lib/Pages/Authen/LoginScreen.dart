import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 28,
                          color: AppColors.black,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildLabel('USERNAME HOẶC EMAIL'),
                      const SizedBox(height: 8),
                      Inputcomponent(
                        hintText: 'Nhập username hoặc email',
                        controller: _usernameController,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('MẬT KHẨU'),
                      const SizedBox(height: 8),
                      Inputcomponent(
                        hintText: 'Nhập mật khẩu',
                        controller: _passwordController,
                        obscureText: true,
                      ),

                      const SizedBox(height: 24),
                      
                      Obx(() {
                        final isLoading = AuthenticationRepository.instance.isLoading.value;
                        return ButtonComponent(
                          text: 'Đăng nhập'.toUpperCase(),
                          width: double.infinity,
                          height: 52,
                          color: AppColors.buttonColor,
                          textColor: Colors.white,
                          borderWidth: 0,
                          borderRadius: 12,
                          textWeight: FontWeight.w700,
                          onPressed: isLoading ? null : () async {
                            final identifier = _usernameController.text.trim();
                            final password = _passwordController.text.trim();
                            if (identifier.isNotEmpty && password.isNotEmpty) {
                              if (identifier.contains('@')) {
                                await AuthenticationRepository.instance.loginWithEmailAndPassword(identifier, password);
                              } else {
                                await AuthenticationRepository.instance.loginWithUsernameAndPassword(identifier, password);
                              }
                            } else {
                              Get.snackbar("Thông báo", "Vui lòng nhập đầy đủ thông tin",
                                  snackPosition: SnackPosition.BOTTOM);
                            }
                          },
                        );
                      }),
                      
                      const SizedBox(height: 16),
                      const DividerWithCenter(centerText: 'Hoặc'),
                      const SizedBox(height: 16),
                      const AuthSocialButtons(),
                      const SizedBox(height: 24),
                      
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
          Obx(() {
            if (AuthenticationRepository.instance.isLoading.value) {
              return Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.buttonColor,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
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
