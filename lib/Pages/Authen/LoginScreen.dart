import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'email@example.com');
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'EMAIL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Inputcomponent(
                    hintText: 'Nhập email của bạn',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  ButtonComponent(
                    text: 'Đăng nhập'.toUpperCase(),
                    width: double.infinity,
                    height: 52,
                    color: AppColors.buttonColor,
                    textColor: Colors.black,
                    borderWidth: 0,
                    borderRadius: 12,
                    textWeight: FontWeight.w700,
                    onPressed: () {
                      debugPrint('Login with email: ${_emailController.text}');
                    },
                  ),
                  const SizedBox(height: 16),
                  const DividerWithCenter(centerText: 'Hoặc'),
                  const SizedBox(height: 16),
                  const AuthSocialButtons(),
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
}
