import 'package:runvix/export.dart';
import '../Repository/report_repository.dart';

class ReportController extends GetxController {
  static ReportController get instance => Get.find();

  final reportRepo = Get.put(ReportRepository());
  final reports = <ReportModel>[].obs;
  final isLoading = false.obs;

  // Lấy danh sách báo cáo cho một bài viết cụ thể
  Future<void> fetchReportsByPost(String postId) async {
    try {
      isLoading.value = true;
      final result = await reportRepo.getReportsByPost(postId);
      reports.assignAll(result);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải danh sách báo cáo: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Xử lý báo cáo (Xóa báo cáo và có thể xóa bài viết hoặc khóa bài viết)
  Future<void> resolveReport(String reportId, String postId) async {
    try {
      await reportRepo.deleteReport(reportId, postId);
      reports.removeWhere((r) => r.id == reportId);
      
      // Cập nhật lại list posts bên PostController nếu cần
      if (Get.isRegistered<PostController>()) {
        final postController = PostController.instance;
        int index = postController.allPosts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = postController.allPosts[index];
          postController.allPosts[index] = post.copyWith(reportCount: post.reportCount - 1);
        }
      }
      
      Get.snackbar("Thành công", "Đã xử lý báo cáo");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể xử lý báo cáo: $e");
    }
  }
}
