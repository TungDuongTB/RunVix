import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeModel {
  final String? id;
  final String? groupId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String type; // Running, Cycling, etc.
  final double goalValue;
  final String goalUnit; // km, minutes, etc.
  final String imageUrl;

  ChallengeModel({
    this.id,
    this.groupId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.goalValue,
    required this.goalUnit,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "GroupId": groupId,
      "Title": title,
      "Description": description,
      "StartDate": startDate,
      "EndDate": endDate,
      "Type": type,
      "GoalValue": goalValue,
      "GoalUnit": goalUnit,
      "ImageUrl": imageUrl,
    };
  }

  factory ChallengeModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ChallengeModel(
      id: document.id,
      groupId: data["GroupId"],
      title: data["Title"] ?? "",
      description: data["Description"] ?? "",
      startDate: (data["StartDate"] as Timestamp).toDate(),
      endDate: (data["EndDate"] as Timestamp).toDate(),
      type: data["Type"] ?? "Running",
      goalValue: (data["GoalValue"] ?? 0).toDouble(),
      goalUnit: data["GoalUnit"] ?? "km",
      imageUrl: data["ImageUrl"] ?? "",
    );
  }
}
