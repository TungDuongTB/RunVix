import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String receiverId;
  final String type; // follow, follow_back, friend, like, comment, system
  final List<String> senderIds; // List of user IDs triggering this notification (for grouping)
  final String? postId;
  final String? commentId;
  final String? title;
  final String? body;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    this.id,
    required this.receiverId,
    required this.type,
    required this.senderIds,
    this.postId,
    this.commentId,
    this.title,
    this.body,
    this.isRead = false,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "ReceiverId": receiverId,
      "Type": type,
      "SenderIds": senderIds,
      "PostId": postId,
      "CommentId": commentId,
      "Title": title,
      "Body": body,
      "IsRead": isRead,
      "CreatedAt": createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory NotificationModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NotificationModel(
      id: doc.id,
      receiverId: data["ReceiverId"] ?? "",
      type: data["Type"] ?? "",
      senderIds: List<String>.from(data["SenderIds"] ?? []),
      postId: data["PostId"],
      commentId: data["CommentId"],
      title: data["Title"],
      body: data["Body"],
      isRead: data["IsRead"] ?? false,
      createdAt: data["CreatedAt"] != null ? (data["CreatedAt"] as Timestamp).toDate() : null,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? receiverId,
    String? type,
    List<String>? senderIds,
    String? postId,
    String? commentId,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      senderIds: senderIds ?? this.senderIds,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
