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
  final int reportCount;
  final bool isLocked;
  final bool isLiked;

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
    this.reportCount = 0,
    this.isLocked = false,
    this.isLiked = false,
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
      "ReportCount": reportCount,
      "IsLocked": isLocked,
    };
  }

  factory PostModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document, {String? userName, String? userProfilePicture}) {
    final data = document.data() ?? {};
    return PostModel(
      id: document.id,
      userId: data["UserId"] ?? "",
      userName: userName ?? "",
      userProfilePicture: userProfilePicture ?? "",
      title: data["Title"] ?? "",
      content: data["Content"] ?? "",
      imageUrl: data["ImageUrl"] ?? "",
      createdAt: data["CreatedAt"] != null ? (data["CreatedAt"] as Timestamp).toDate() : null,
      likes: (data["Likes"] ?? 0) as int,
      comments: (data["Comments"] ?? 0) as int,
      reportCount: (data["ReportCount"] ?? 0) as int,
      isLocked: data["IsLocked"] == true, // Ép kiểu về bool an toàn
      isLiked: false, // Sẽ được cập nhật lại trong Repository
    );
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfilePicture,
    String? title,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    int? likes,
    int? comments,
    bool? isLocked,
    int? reportCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePicture: userProfilePicture ?? this.userProfilePicture,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      reportCount: reportCount ?? this.reportCount,
      isLocked: isLocked ?? this.isLocked,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
