import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../Model/workout_model.dart';
import '../Repository/workout_repository.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final _workoutRepo = Get.put(WorkoutRepository());
  final workouts = <WorkoutModel>[].obs;
  final isLoading = false.obs;

  // Stats
  var totalDistance = 0.0.obs;
  var totalDuration = 0.obs;
  var workoutCount = 0.obs;

  // Personal Records
  var maxDistance = 0.0.obs; // meters
  var maxDuration = 0.obs; // seconds
  var bestPace = 0.0.obs; // seconds per km

  @override
  void onInit() {
    super.onInit();
    fetchUserWorkouts();
  }

  Future<void> fetchUserWorkouts() async {
    try {
      isLoading.value = true;
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final data = await _workoutRepo.getUserWorkouts(userId);
        workouts.assignAll(data);
        _calculateStats();
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải dữ liệu hoạt động");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    double dist = 0;
    int dur = 0;

    double mDist = 0;
    int mDur = 0;
    double bPace = double.infinity;

    for (var w in workouts) {
      dist += w.distance;
      dur += w.duration;

      if (w.distance > mDist) mDist = w.distance;
      if (w.duration > mDur) mDur = w.duration;

      if (w.distance > 0) {
        double distanceKm = w.distance / 1000;
        if (distanceKm > 0) {
          double paceSecPerKm = w.duration / distanceKm;
          // Pace hợp lý cho chạy bộ thường > 2 phút/km (120s/km) để tránh nhiễu GPS
          if (paceSecPerKm > 120 && paceSecPerKm < bPace) {
            bPace = paceSecPerKm;
          }
        }
      }
    }
    totalDistance.value = dist;
    totalDuration.value = dur;
    workoutCount.value = workouts.length;

    maxDistance.value = mDist;
    maxDuration.value = mDur;
    bestPace.value = bPace == double.infinity ? 0.0 : bPace;
  }
}
