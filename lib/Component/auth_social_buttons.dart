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
          // SỬA Ở ĐÂY: Gọi hàm từ Repository thay vì print
          onPressed: () => AuthenticationRepository.instance.signInWithGoogle(),
        ),
      ],
    );
  }
}
