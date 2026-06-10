import 'package:get/get.dart';
import '../../export.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Các Repository quan trọng
    Get.put(UserRepository(), permanent: true);
    Get.put(AuthenticationRepository(), permanent: true);
    Get.put(PostRepository(), permanent: true);
    Get.put(WorkoutRepository(), permanent: true);
    Get.put(NotificationRepository(), permanent: true);
    
    // Các Controller
    Get.put(UserController(), permanent: true);
    Get.put(PostController(), permanent: true);
    Get.put(ReportController(), permanent: true);
    Get.put(CalendarController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
    Get.put(NotificationController(), permanent: true);
    
    // Strava - Khởi tạo ngay lập tức để tránh lỗi undefined trên Web
    Get.put(StravaRepository(), permanent: true);
    Get.put(StravaController(), permanent: true);
  }
}
