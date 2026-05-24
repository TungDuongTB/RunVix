import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
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
}
