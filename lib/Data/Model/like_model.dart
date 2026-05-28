import 'package:cloud_firestore/cloud_firestore.dart';

class LikeModel {
  final String? id;
  final String postId;
  final String userId;
  final DateTime? createdAt;

  LikeModel({
    this.id,
    required this.postId,
    required this.userId,
    this.createdAt,
  });

  toJson() {
    return {
      "PostId": postId,
      "UserId": userId,
      "CreatedAt": createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory LikeModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return LikeModel(
      id: document.id,
      postId: data["PostId"] ?? "",
      userId: data["UserId"] ?? "",
      createdAt: data["CreatedAt"] != null ? (data["CreatedAt"] as Timestamp).toDate() : null,
    );
  }
}
