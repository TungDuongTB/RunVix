import 'package:get/get.dart';
import '../../export.dart';

class MapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StravaRepository());
    Get.lazyPut(() => StravaController());
  }
}
