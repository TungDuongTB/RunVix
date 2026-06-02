import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Obx(() {
            final isLoading = AuthenticationRepository.instance.isLoading.value;
            return OutlinedButton(
              onPressed: isLoading ? null : () => AuthenticationRepository.instance.signInWithGoogle(),
              style: OutlinedButton.styleFrom(
                backgroundColor: isLoading ? Colors.grey.shade100 : Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: isLoading ? 0.5 : 1.0,
                    child: Image.asset(
                      'assets/Images/google.png',
                      height: 22,
                      width: 22,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.g_mobiledata, color: Colors.red),
                    ),
                  ),

                  const SizedBox(width: 12),
                  Text(
                    'Tiếp tục với Google',
                    style: TextStyle(
                      color: isLoading ? Colors.grey : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}