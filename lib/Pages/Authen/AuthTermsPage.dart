import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class AuthTermsPage extends StatefulWidget {
  const AuthTermsPage({super.key});

  @override
  State<AuthTermsPage> createState() => _AuthTermsPageState();
}

class _AuthTermsPageState extends State<AuthTermsPage> {
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;
  late TapGestureRecognizer _cookieRecognizer;
  late TapGestureRecognizer _hereRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = () => print('Terms tapped');
    _privacyRecognizer = TapGestureRecognizer()..onTap = () => print('Privacy tapped');
    _cookieRecognizer = TapGestureRecognizer()..onTap = () => print('Cookie tapped');
    _hereRecognizer = TapGestureRecognizer()..onTap = () => print('Here tapped');
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _cookieRecognizer.dispose();
    _hereRecognizer.dispose();
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
          icon: const Icon(Icons.close, color: AppColors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RUNVIX',
                    style: TextStyle(
                      color: Color(0xFFFF4500), // Màu cam giống Strava
                      fontSize: 24,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cập nhật Điều khoản\nDịch vụ và Chính sách',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.black,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Vui lòng đọc '),
                        TextSpan(
                          text: 'Điều khoản Dịch vụ',
                          style: const TextStyle(
                            color: Color(0xFFFF4500),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _termsRecognizer,
                        ),
                        const TextSpan(text: ', '),
                        TextSpan(
                          text: 'Chính sách Quyền riêng tư',
                          style: const TextStyle(
                            color: Color(0xFFFF4500),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _privacyRecognizer,
                        ),
                        const TextSpan(text: ' và '),
                        TextSpan(
                          text: 'Chính sách Cookie',
                          style: const TextStyle(
                            color: Color(0xFFFF4500),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _cookieRecognizer,
                        ),
                        const TextSpan(
                          text: ' đã được cập nhật của chúng tôi. Bạn cũng có thể tìm hiểu thêm về các bản cập nhật này tại ',
                        ),
                        TextSpan(
                          text: 'tại đây',
                          style: const TextStyle(
                            color: Color(0xFFFF4500),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _hereRecognizer,
                        ),
                        const TextSpan(text: '. Các cập nhật này sẽ có hiệu lực từ ngày 1 tháng 1 năm 2026.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Bằng việc tiếp tục sử dụng Runvix, bạn đồng ý với các cập nhật này.',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.black,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ButtonComponent(
              text: 'Đồng ý và Tiếp tục',
              width: double.infinity,
              height: 56,
              color: const Color(0xFFFF4500),
              textColor: Colors.white,
              borderRadius: 8,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
