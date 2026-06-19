import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileStatistics {
  final int tripCount;
  final double totalDistance; // in meters
  final double averageDuration; // in seconds

  ProfileStatistics({
    required this.tripCount,
    required this.totalDistance,
    required this.averageDuration,
  });

  factory ProfileStatistics.fromMap(Map<String, dynamic> map) {
    return ProfileStatistics(
      tripCount: (map['tripCount'] ?? 0) as int,
      totalDistance: (map['totalDistance'] ?? 0).toDouble(),
      averageDuration: (map['averageDuration'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripCount': tripCount,
      'totalDistance': totalDistance,
      'averageDuration': averageDuration,
    };
  }
}
