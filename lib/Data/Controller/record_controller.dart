import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Model/workout_model.dart';
import '../Repository/workout_repository.dart';

class RecordController extends GetxController {
  static RecordController get instance => Get.find();

  final _workoutRepo = Get.put(WorkoutRepository());
  
  // States
  var isRecording = false.obs;
  var isPaused = false.obs;
  var duration = 0.obs; // seconds
  var distance = 0.0.obs; // meters
  var pace = 0.0.obs; // min/km
  
  var polylinePoints = <LatLng>[].obs;
  Timer? _timer;
  StreamSubscription<Position>? _positionStream;

  void startRecording() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    isRecording.value = true;
    isPaused.value = false;
    _startTimer();
    _startLocationTracking();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused.value) {
        duration.value++;
        _calculatePace();
      }
    });
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Cập nhật mỗi 5 mét
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (!isPaused.value) {
        LatLng newPoint = LatLng(position.latitude, position.longitude);
        
        if (polylinePoints.isNotEmpty) {
          double distanceBetween = Geolocator.distanceBetween(
            polylinePoints.last.latitude,
            polylinePoints.last.longitude,
            position.latitude,
            position.longitude,
          );
          distance.value += distanceBetween;
        }
        
        polylinePoints.add(newPoint);
      }
    });
  }

  void _calculatePace() {
    if (distance.value > 0) {

      pace.value = (duration.value / 60) / (distance.value / 1000);
    }
  }

  void pauseRecording() {
    isPaused.value = true;
  }

  void resumeRecording() {
    isPaused.value = false;
  }

  void stopRecording() async {
    _timer?.cancel();
    _positionStream?.cancel();
    
    if (distance.value >=0) { // Chỉ lưu nếu chạy trên 10m
      final workout = WorkoutModel(
        userId: FirebaseAuth.instance.currentUser?.uid ?? "",
        type: "Running",
        distance: distance.value,
        duration: duration.value,
        averagePace: pace.value,
        timestamp: DateTime.now(),
        route: polylinePoints.map((p) => GeoPoint(p.latitude, p.longitude)).toList(),
      );
      await _workoutRepo.saveWorkout(workout);
      Get.snackbar("Thành công", "Đã lưu hoạt động của bạn!");
    }

    _resetStats();
  }

  void _resetStats() {
    isRecording.value = false;
    isPaused.value = false;
    duration.value = 0;
    distance.value = 0.0;
    pace.value = 0.0;
    polylinePoints.clear();
  }
  @override
  void onClose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.onClose();
  }
}
