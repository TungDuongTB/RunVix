import 'package:cloud_firestore/cloud_firestore.dart';

class GroupEventModel {
  final String? id;
  final String groupId;
  final String title;
  final DateTime eventDate;
  final String time;
  final String imageUrl;
  final String creatorId;
  final DateTime? createdAt;

  const GroupEventModel({
    this.id,
    required this.groupId,
    required this.title,
    required this.eventDate,
    this.time = '',
    this.imageUrl = '',
    required this.creatorId,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'EventDate': Timestamp.fromDate(eventDate),
      'Time': time,
      'ImageUrl': imageUrl,
      'CreatorId': creatorId,
      'CreatedAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory GroupEventModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String groupId,
  ) {
    final data = doc.data()!;
    return GroupEventModel(
      id: doc.id,
      groupId: groupId,
      title: data['Title'] ?? '',
      eventDate: data['EventDate'] != null
          ? (data['EventDate'] as Timestamp).toDate()
          : DateTime.now(),
      time: data['Time'] ?? '',
      imageUrl: data['ImageUrl'] ?? '',
      creatorId: data['CreatorId'] ?? '',
      createdAt: data['CreatedAt'] != null
          ? (data['CreatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
