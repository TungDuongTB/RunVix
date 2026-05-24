import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class Signin extends StatelessWidget {
  const Signin({super.key});

  @override
  Widget build(BuildContext context) {
    final termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Get.toNamed('/terms'); 
      };
    final privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        print('Chính sách Quyền riêng tư tapped');
      };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tạo tài khoản',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ButtonComponent(
                    text: 'Tiếp tục với Google',
                    width: double.infinity,
                    height: 48,
                    color: CupertinoColors.white,
                    textColor: CupertinoColors.black,
                    borderColor: CupertinoColors.inactiveGray,
                    borderWidth: 1,
                    borderRadius: 50,
                    // GỌI HÀM Ở ĐÂY
                    onPressed: () => AuthenticationRepository.instance.signInWithGoogle(),
                  ),
                  const SizedBox(height: 12),
                  ButtonComponent(
                    text: 'Tiếp tục với Apple',
                    width: double.infinity,
                    height: 48,
                    color: CupertinoColors.white,
                    textColor: CupertinoColors.black,
                    borderColor: CupertinoColors.inactiveGray,
                    borderWidth: 1,
                    borderRadius: 50,
                    onPressed: () {
                      print('Tiếp tục với Apple pressed');
                    },
                  ),
                  const SizedBox(height: 16),
                  const DividerWithCenter(centerText: 'Hoặc'),
                  const SizedBox(height: 16),

                  ButtonComponent(
                    text: 'Đăng ký bằng email',
                    width: double.infinity,
                    height: 48,
                    color: AppColors.buttonColor,
                    textColor: CupertinoColors.white,
                    borderWidth: 0,
                    borderRadius: 8,
                    onPressed: () {
                      Get.to(() => const RegisterScreen());
                    },
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: CupertinoColors.inactiveGray,
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(text: 'Khi tiếp tục, bạn đồng ý với '),
                          TextSpan(
                            text: 'điều khoản dịch vụ',
                            style: const TextStyle(
                              color: CupertinoColors.activeBlue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: termsRecognizer,
                          ),
                          const TextSpan(text: ' và '),
                          TextSpan(
                            text: 'chính sách Quyền riêng tư',
                            style: const TextStyle(
                              color: CupertinoColors.activeBlue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: privacyRecognizer,
                          ),
                          const TextSpan(text: ' của chúng tôi'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
