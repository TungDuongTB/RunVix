import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String? id;
  final String postId;
  final String userId;
  final String userName;
  final String userProfilePicture;
  final String comment;
  final DateTime? createdAt;
  final bool isHidden;

  CommentModel({
    this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userProfilePicture,
    required this.comment,
    this.createdAt,
    this.isHidden = false,
  });

  toJson() {
    return {
      "PostId": postId,
      "UserId": userId,
      "UserName": userName,
      "UserProfilePicture": userProfilePicture,
      "Comment": comment,
      "IsHidden": isHidden,
      "CreatedAt": createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory CommentModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return CommentModel(
      id: document.id,
      postId: data["PostId"] ?? "",
      userId: data["UserId"] ?? "",
      userName: data["UserName"] ?? "",
      userProfilePicture: data["UserProfilePicture"] ?? "",
      comment: data["Comment"] ?? "",
      isHidden: data["IsHidden"] == true,
      createdAt: data["CreatedAt"] != null
          ? (data["CreatedAt"] as Timestamp).toDate()
          : null,
    );
  }
}
