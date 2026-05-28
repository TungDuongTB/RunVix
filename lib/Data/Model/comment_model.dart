import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String? id;
  final String postId;
  final String userId;
  final String userName;
  final String userProfilePicture;
  final String comment;
  final DateTime? createdAt;

  CommentModel({
    this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userProfilePicture,
    required this.comment,
    this.createdAt,
  });

  toJson() {
    return {
      "PostId": postId,
      "UserId": userId,
      "UserName": userName,
      "UserProfilePicture": userProfilePicture,
      "Comment": comment,
      "CreatedAt": createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory CommentModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return CommentModel(
      id: document.id,
      postId: data["PostId"] ?? "",
      userId: data["UserId"] ?? "",
      userName: data["UserName"] ?? "",
      userProfilePicture: data["UserProfilePicture"] ?? "",
      comment: data["Comment"] ?? "",
      createdAt: data["CreatedAt"] != null ? (data["CreatedAt"] as Timestamp).toDate() : null,
    );
  }
}
