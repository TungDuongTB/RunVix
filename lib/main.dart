
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:runvix/firebase_options.dart'; 
import 'export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  
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

  // Luôn nạp Repository qua InitialBinding
  print("📦 Đang khởi tạo ứng dụng với InitialBinding...");

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
      initialRoute: '/',
      initialBinding: InitialBinding(),
      getPages: [
        GetPage(name: '/', page: () => const LoadingScreen()),
        GetPage(name: '/login', page: () => const Loginscreen()),
        GetPage(
          name: '/home', 
          page: () => const HomeScreen(),
          binding: MapBinding(),
        ),
        GetPage(name: '/admin-dashboard', page: () => const AdminDashboardScreen()),
        GetPage(name: '/profile-hub', page: () => const ProfileHubScreen()),
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.orangeRed,
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
