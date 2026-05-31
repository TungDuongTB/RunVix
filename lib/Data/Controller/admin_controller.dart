import 'package:get/get.dart';
import '../Model/admin_stats_model.dart';
import '../Repository/admin_repository.dart';

class AdminController extends GetxController {
  static AdminController get instance => Get.find();

  final _repository = AdminRepository();
  final isLoading = false.obs;
  final stats = Rxn<AdminStatsModel>();

  @override
  void onInit() {
    super.onInit();
    fetchAdminStats();
  }

  Future<void> fetchAdminStats() async {
    try {
      isLoading.value = true;
      final data = await _repository.getAdminStats();
      stats.value = data;
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải số liệu thống kê: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
