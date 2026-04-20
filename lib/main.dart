import 'package:flutter/material.dart';
import 'export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => Get.put(AuthenticationRepository()));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RunVix',
      debugShowCheckedModeBanner: false,
      // 1. Ép buộc ứng dụng luôn ở chế độ sáng
      themeMode: ThemeMode.light, 
      
      // 2. Cấu hình Theme chung cho toàn app
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white, // Nền của các trang (Scaffold)
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4500),
          brightness: Brightness.light,
          surface: Colors.white, // Nền của các thành phần như Card, Dialog
        ),

        // Cấu hình mặc định cho AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),

      home: const HomeScreen(),
    );
  }
}
