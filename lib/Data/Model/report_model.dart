import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String? id;
  final String postId;      // ID bài viết bị báo cáo
  final String reporterId;  // ID người thực hiện báo cáo
  final String reporterName;
  final String reason;      // Nội dung/Lý do báo cáo
  final DateTime? createdAt;

  ReportModel({
    this.id,
    required this.postId,
    required this.reporterId,
    this.reporterName = "Người dùng",
    required this.reason,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "PostId": postId,
      "ReporterId": reporterId,
      "ReporterName": reporterName,
      "Reason": reason,
      "CreatedAt": createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory ReportModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ReportModel(
      id: document.id,
      postId: data["PostId"] ?? "",
      reporterId: data["ReporterId"] ?? "",
      reporterName: data["ReporterName"] ?? "Người dùng",
      reason: data["Reason"] ?? "",
      createdAt: data["CreatedAt"] != null ? (data["CreatedAt"] as Timestamp).toDate() : null,
    );
  }
}
