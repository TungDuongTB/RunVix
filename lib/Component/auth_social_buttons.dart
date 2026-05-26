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
          child: OutlinedButton(
            onPressed: () => AuthenticationRepository.instance.signInWithGoogle(),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Images/google.png',
                  height: 22,
                  width: 22,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.g_mobiledata, color: Colors.red),
                ),

                const SizedBox(width: 12),
                const Text(
                  'Tiếp tục với Google',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}