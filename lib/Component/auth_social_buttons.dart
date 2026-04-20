import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ButtonComponent(
          text: 'Tiếp tục với Google',
          width: double.infinity,
          height: 48,
          color: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey.shade300,
          borderWidth: 1,
          borderRadius: 50,
          onPressed: () => print('Google login'),
        ),
        const SizedBox(height: 12),
        ButtonComponent(
          text: 'Tiếp tục với Apple',
          width: double.infinity,
          height: 48,
          color: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey.shade300,
          borderWidth: 1,
          borderRadius: 50,
          onPressed: () => print('Apple login'),
        ),
      ],
    );
  }
}
