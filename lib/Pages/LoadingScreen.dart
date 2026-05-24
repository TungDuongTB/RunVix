import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthenticationRepository.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Obx(
          () {
            final user = authRepo.firebaseUser.value;

            // Nếu user đã login, chuyển hướng tới Home
            if (user != null) {
              // Gọi _setInitialScreen để chuyển hướng
              Future.microtask(() => authRepo.firebaseUser.refresh());
              return const CircularProgressIndicator();
            }

            // Nếu đang loading, hiển thị loading spinner
            if (authRepo.isLoading.value) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Đang tải...'),
                ],
              );
            }

            // Nếu chưa login, hiển thị button đăng nhập
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Chào mừng đến RunVix',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                ButtonComponent(
                  text: 'Đăng nhập',
                  height: 45,
                  color: AppColors.buttonColor,
                  width: 200,
                  textColor: Colors.white,
                  onPressed: () {
                    Get.to(() => const Loginscreen());
                  },
                ),
                const SizedBox(height: 16),
                ButtonComponent(
                  text: 'Đăng ký',
                  height: 45,
                  color: Colors.grey[300]!,
                  width: 200,
                  textColor: Colors.black,
                  onPressed: () {
                    Get.to(() => const Signin());
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
