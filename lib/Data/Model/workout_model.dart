import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
  final String? id;
  final String userId;
  final String type;
  final double distance;
  final int duration;
  final double averagePace;
  final DateTime timestamp;
  final List<GeoPoint> route;

  WorkoutModel({
    this.id,
    required this.userId,
    required this.type,
    required this.distance,
    required this.duration,
    required this.averagePace,
    required this.timestamp,
    required this.route,
  });

  Map<String, dynamic> toJson() {
    return {
      "UserId": userId,
      "Type": type,
      "Distance": distance,
      "Duration": duration,
      "AveragePace": averagePace,
      "Timestamp": timestamp,
      "Route": route,
    };
  }

  factory WorkoutModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return WorkoutModel(
      id: document.id,
      userId: data["UserId"] ?? "",
      type: data["Type"] ?? "Running",
      distance: (data["Distance"] ?? 0).toDouble(),
      duration: data["Duration"] ?? 0,
      averagePace: (data["AveragePace"] ?? 0).toDouble(),
      timestamp: (data["Timestamp"] as Timestamp).toDate(),
      route: List<GeoPoint>.from(data["Route"] ?? []),
    );
  }
}
