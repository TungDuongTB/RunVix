import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class AuthTermsAgreement extends StatefulWidget {
  const AuthTermsAgreement({super.key});

  @override
  State<AuthTermsAgreement> createState() => _AuthTermsAgreementState();
}

class _AuthTermsAgreementState extends State<AuthTermsAgreement> {
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuthTermsPage()),
        );
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        // Handle Privacy Policy tap
        debugPrint('Privacy Policy tapped');
      };
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
          children: [
            const TextSpan(text: 'Khi tiếp tục, bạn đồng ý với '),
            TextSpan(
              text: 'điều khoản dịch vụ',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: _termsRecognizer,
            ),
            const TextSpan(text: ' và '),
            TextSpan(
              text: 'chính sách Quyền riêng tư',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: _privacyRecognizer,
            ),
            const TextSpan(text: ' của chúng tôi'),
          ],
        ),
      ),
    );
  }
}
