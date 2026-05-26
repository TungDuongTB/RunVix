import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:runvix/firebase_options.dart'; // File này sẽ được sinh ra khi anh chạy lệnh cấu hình
import 'export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("🚀 Khởi động ứng dụng RunVix...");

  try {
    print("📱 Đang khởi tạo Firebase...");
    // Tự động nhận diện Android, iOS hay Web để lấy cấu hình phù hợp
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase đã được khởi tạo thành công!");
  } catch (e) {
    print("❌ Lỗi khởi tạo Firebase: $e");
    print("⚠️ Ứng dụng sẽ tiếp tục chạy nhưng các tính năng Firebase sẽ bị hạn chế.");
    print("📋 Hướng dẫn: Mở Terminal và chạy lệnh 'flutterfire configure' để tạo file cấu hình.");
  }

  // Luôn nạp Repository để tránh lỗi "not found"
  print("📦 Đang tải Repositories...");
  Get.put(UserRepository());
  Get.put(UserController()); // Khởi tạo UserController ngay từ đầu
  Get.put(AuthenticationRepository());
  Get.put(CalendarController()); // Khởi tạo sớm để tránh lỗi UI
  print("✅ Repositories đã sẵn sàng!");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RunVix',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      initialRoute: '/', // Xác định rõ route khởi đầu
      getPages: [
        GetPage(name: '/', page: () => const LoadingScreen()),
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4500),
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}
