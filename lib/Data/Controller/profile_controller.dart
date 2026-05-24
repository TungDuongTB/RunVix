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
    for (var w in workouts) {
      dist += w.distance;
      dur += w.duration;
    }
    totalDistance.value = dist;
    totalDuration.value = dur;
    workoutCount.value = workouts.length;
  }
}
