import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:runvix/export.dart';

class Signin extends StatelessWidget {
  const Signin({super.key});

  @override
  Widget build(BuildContext context) {
    final termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        print('Điều khoản dịch vụ tapped');
      };
    final privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        print('Chính sách Quyền riêng tư tapped');
      };

    return SafeArea(
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
                  onPressed: () {
                    print('Đăng nhập pressed');
                  },
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
                    print('Tạo mới pressed');
                  },
                ),
                const SizedBox(height: 16),
                const DividerWithCenter(centerText: 'Hoặc'), // centered text
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
                    print('Email signup pressed');
                  },
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
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
    );
  }
}
