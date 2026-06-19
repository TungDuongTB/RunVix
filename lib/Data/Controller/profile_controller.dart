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

  // Period Stats
  var selectedPeriod = 'year'.obs; // 'year' là mặc định thay vì 'week'
  var periodDistance = 0.0.obs;
  var periodDuration = 0.obs;
  var periodWorkoutCount = 0.obs;
  var chartData = <double>[].obs;
  var chartLabels = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserWorkouts();
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    updatePeriodStats();
  }

  Future<void> fetchUserWorkouts() async {
    try {
      isLoading.value = true;
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final data = await _workoutRepo.getUserWorkouts(userId);
        workouts.assignAll(data);
        _calculateStats();
        updatePeriodStats();
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

  void updatePeriodStats() {
    final now = DateTime.now();
    double dist = 0;
    int dur = 0;
    int count = 0;

    List<double> tempChartData = [];
    List<String> tempChartLabels = [];

    if (selectedPeriod.value == 'week') {
      // Tuần này (Thứ 2 - Chủ nhật)
      // Lấy ngày đầu tuần (Thứ 2)
      final weekday = now.weekday;
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      // 7 ngày trong tuần
      tempChartData = List.filled(7, 0.0);
      tempChartLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

      for (var w in workouts) {
        if (w.timestamp.isAfter(startOfWeek) && w.timestamp.isBefore(endOfWeek)) {
          dist += w.distance;
          dur += w.duration;
          count++;

          int dayIndex = w.timestamp.weekday - 1; // 0 - 6
          if (dayIndex >= 0 && dayIndex < 7) {
            tempChartData[dayIndex] += w.distance / 1000; // km
          }
        }
      }
    } else if (selectedPeriod.value == 'month') {
      // Tháng này
      final startOfMonth = DateTime(now.year, now.month, 1);
      final nextMonth = now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);

      // Chia thành 4 tuần
      tempChartData = List.filled(4, 0.0);
      tempChartLabels = ['T.1', 'T.2', 'T.3', 'T.4'];

      for (var w in workouts) {
        if (w.timestamp.isAfter(startOfMonth) && w.timestamp.isBefore(nextMonth)) {
          dist += w.distance;
          dur += w.duration;
          count++;

          // Tính xem thuộc tuần mấy trong tháng
          int day = w.timestamp.day;
          int weekIndex = (day - 1) ~/ 7;
          if (weekIndex > 3) weekIndex = 3;
          tempChartData[weekIndex] += w.distance / 1000;
        }
      }
    } else if (selectedPeriod.value == 'year') {
      // Năm này
      final startOfYear = DateTime(now.year, 1, 1);
      final endOfYear = DateTime(now.year + 1, 1, 1);

      // 12 tháng
      tempChartData = List.filled(12, 0.0);
      tempChartLabels = ['Th.1', 'Th.2', 'Th.3', 'Th.4', 'Th.5', 'Th.6', 'Th.7', 'Th.8', 'Th.9', 'Th.10', 'Th.11', 'Th.12'];

      for (var w in workouts) {
        if (w.timestamp.isAfter(startOfYear) && w.timestamp.isBefore(endOfYear)) {
          dist += w.distance;
          dur += w.duration;
          count++;

          int monthIndex = w.timestamp.month - 1; // 0 - 11
          if (monthIndex >= 0 && monthIndex < 12) {
            tempChartData[monthIndex] += w.distance / 1000;
          }
        }
      }
    }

    periodDistance.value = dist;
    periodDuration.value = dur;
    periodWorkoutCount.value = count;
    chartData.assignAll(tempChartData);
    chartLabels.assignAll(tempChartLabels);
  }
}
