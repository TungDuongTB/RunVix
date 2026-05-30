
import '../../export.dart';
import '../Model/report_model.dart';

class ReportRepository extends GetxController {
  static ReportRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  // Tạo báo cáo mới
  Future<void> createReport(ReportModel report) async {
    try {
      await _db.collection("Reports").add(report.toJson());
      
      // Cập nhật số lượng báo cáo trong Post document (Denormalization để xem nhanh)
      await _db.collection("Posts").doc(report.postId).update({
        "ReportCount": FieldValue.increment(1)
      });
    } catch (e) {
      throw "Đã xảy ra lỗi khi gửi báo cáo: $e";
    }
  }

  // Lấy danh sách báo cáo của một bài viết
  Future<List<ReportModel>> getReportsByPost(String postId) async {
    try {
      final snapshot = await _db
          .collection("Reports")
          .where("PostId", isEqualTo: postId)
          .orderBy("CreatedAt", descending: true)
          .get();
      
      return snapshot.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw "Không thể tải danh sách báo cáo: $e";
    }
  }

  // Xóa báo cáo (khi admin xử lý xong hoặc bác bỏ)
  Future<void> deleteReport(String reportId, String postId) async {
    try {
      await _db.collection("Reports").doc(reportId).delete();
      
      // Giảm số lượng báo cáo trong Post
      await _db.collection("Posts").doc(postId).update({
        "ReportCount": FieldValue.increment(-1)
      });
    } catch (e) {
      throw "Không thể xóa báo cáo: $e";
    }
  }
}
