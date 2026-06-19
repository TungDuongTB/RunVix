import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../Model/group_workout_stats.dart';
import '../Model/workout_model.dart';

class WorkoutRepository extends GetxController {
  static WorkoutRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<void> saveWorkout(WorkoutModel workout) async {
    try {
      await _db.collection("Workouts").add(workout.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<WorkoutModel>> getUserWorkouts(String userId) async {
    try {
      final snapshot = await _db
          .collection("Workouts")
          .where("UserId", isEqualTo: userId)
          .orderBy("Timestamp", descending: true)
          .get();
      
      return snapshot.docs.map((doc) => WorkoutModel.fromSnapshot(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Tổng km của các thành viên nhóm trong tuần hiện tại (Thứ 2 - CN)
  Future<double> getGroupWeeklyKm(List<String> memberIds) async {
    if (memberIds.isEmpty) return 0.0;

    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    double totalMeters = 0;
    try {
      for (var i = 0; i < memberIds.length; i += 10) {
        final chunk = memberIds.sublist(
            i, i + 10 > memberIds.length ? memberIds.length : i + 10);
        final snap = await _db
            .collection('Workouts')
            .where('UserId', whereIn: chunk)
            .where('Timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
            .where('Timestamp', isLessThan: Timestamp.fromDate(endOfWeek))
            .get();
        for (final doc in snap.docs) {
          totalMeters += (doc.data()['Distance'] as num? ?? 0).toDouble();
        }
      }
    } catch (_) {}
    return totalMeters / 1000; // trả về km
  }


  Future<GroupWorkoutStats> getGroupWorkoutStats(List<String> memberIds) async {
    if (memberIds.isEmpty) return GroupWorkoutStats.empty();

    double totalDistanceMeters = 0;
    int totalDurationSeconds = 0;

    try {
      for (var i = 0; i < memberIds.length; i += 10) {
        final end = (i + 10 > memberIds.length) ? memberIds.length : i + 10;
        final chunk = memberIds.sublist(i, end);

        final snapshot = await _db
            .collection('Workouts')
            .where('UserId', whereIn: chunk)
            .get();

        for (final doc in snapshot.docs) {
          final workout = WorkoutModel.fromSnapshot(doc);
          totalDistanceMeters += workout.distance;
          totalDurationSeconds += workout.duration;
        }
      }

      final averagePace = totalDistanceMeters > 0
          ? (totalDurationSeconds / 60) / (totalDistanceMeters / 1000)
          : 0.0;

      return GroupWorkoutStats(
        totalDistanceMeters: totalDistanceMeters,
        averagePace: averagePace,
      );
    } catch (e) {
      throw 'Không thể tải thống kê hoạt động của nhóm.';
    }
  }
}
