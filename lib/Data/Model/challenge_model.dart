import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeModel {
  final String? id;
  final String? groupId;
  final String? creatorId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String type; // Running, Cycling, etc.
  final double goalValue;
  final String goalUnit; // km, minutes, etc.
  final String imageUrl;
  final List<String> joinedUserIds;

  ChallengeModel({
    this.id,
    this.groupId,
    this.creatorId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.goalValue,
    required this.goalUnit,
    required this.imageUrl,
    this.joinedUserIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      "GroupId": groupId,
      "CreatorId": creatorId,
      "Title": title,
      "Description": description,
      "StartDate": startDate,
      "EndDate": endDate,
      "Type": type,
      "GoalValue": goalValue,
      "GoalUnit": goalUnit,
      "ImageUrl": imageUrl,
      "JoinedUserIds": joinedUserIds,
    };
  }

  factory ChallengeModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ChallengeModel(
      id: document.id,
      groupId: data["GroupId"],
      creatorId: data["CreatorId"],
      title: data["Title"] ?? "",
      description: data["Description"] ?? "",
      startDate: (data["StartDate"] as Timestamp).toDate(),
      endDate: (data["EndDate"] as Timestamp).toDate(),
      type: data["Type"] ?? "Running",
      goalValue: (data["GoalValue"] ?? 0).toDouble(),
      goalUnit: data["GoalUnit"] ?? "km",
      imageUrl: data["ImageUrl"] ?? "",
      joinedUserIds: List<String>.from(
        (data["JoinedUserIds"] ?? []).map((e) => e.toString()),
      ),
    );
  }

  ChallengeModel copyWith({
    String? id,
    String? groupId,
    String? creatorId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    double? goalValue,
    String? goalUnit,
    String? imageUrl,
    List<String>? joinedUserIds,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      goalValue: goalValue ?? this.goalValue,
      goalUnit: goalUnit ?? this.goalUnit,
      imageUrl: imageUrl ?? this.imageUrl,
      joinedUserIds: joinedUserIds ?? this.joinedUserIds,
    );
  }
}
