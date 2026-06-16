import 'package:get/get.dart';

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();

  final selectedIndex = 0.obs;
  final profileTabIndex = 0.obs;
  final isBottomNavBarVisible = true.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  void changeProfileTab(int index) {
    profileTabIndex.value = index;
    selectedIndex.value = 4; // Tự động chuyển sang tab "Bạn"
  }

  void setBottomNavBarVisible(bool visible) {
    isBottomNavBarVisible.value = visible;
  }
}
