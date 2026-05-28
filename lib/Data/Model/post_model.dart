import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String? id;
  final String userId;
  final String userName;
  final String userProfilePicture;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime? createdAt;
  final int likes;
  final int comments;

  PostModel({
    this.id,
    required this.userId,
    this.userName = "",
    this.userProfilePicture = "",
    required this.title,
    required this.content,
    required this.imageUrl,
    this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  toJson() {
    return {
      "UserId": userId,
      "Title": title,
      "Content": content,
      "ImageUrl": imageUrl,
      "CreatedAt": createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      "Likes": likes,
      "Comments": comments,
    };
  }

  factory PostModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document, {String? userName, String? userProfilePicture}) {
    final data = document.data()!;
    return PostModel(
      id: document.id,
      userId: data["UserId"] ?? "",
      userName: userName ?? "",
      userProfilePicture: userProfilePicture ?? "",
      title: data["Title"] ?? "",
      content: data["Content"] ?? "",
      imageUrl: data["ImageUrl"] ?? "",
      createdAt: data["CreatedAt"] != null ? (data["CreatedAt"] as Timestamp).toDate() : null,
      likes: data["Likes"] ?? 0,
      comments: data["Comments"] ?? 0,
    );
  }
}
