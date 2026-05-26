import 'package:cloud_firestore/cloud_firestore.dart';

class RouteModel {
  final String? id;
  final String name;
  final String description;
  final double distance; // in meters
  final List<GeoPoint> points;
  final String createdBy;
  final String difficulty; // Easy, Medium, Hard
  final String imageUrl;

  RouteModel({
    this.id,
    required this.name,
    required this.description,
    required this.distance,
    required this.points,
    required this.createdBy,
    required this.difficulty,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "Name": name,
      "Description": description,
      "Distance": distance,
      "Points": points,
      "CreatedBy": createdBy,
      "Difficulty": difficulty,
      "ImageUrl": imageUrl,
    };
  }

  factory RouteModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return RouteModel(
      id: document.id,
      name: data["Name"] ?? "",
      description: data["Description"] ?? "",
      distance: (data["Distance"] ?? 0).toDouble(),
      points: List<GeoPoint>.from(data["Points"] ?? []),
      createdBy: data["CreatedBy"] ?? "",
      difficulty: data["Difficulty"] ?? "Medium",
      imageUrl: data["ImageUrl"] ?? "",
    );
  }
}
