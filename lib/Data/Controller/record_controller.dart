import 'package:runvix/export.dart';

class RecordController extends GetxController {
  static RecordController get instance => Get.find();

  final _workoutRepo = Get.put(WorkoutRepository());
  
  // States
  var isRecording = false.obs;
  var isPaused = false.obs;
  var duration = 0.obs; // seconds
  var distance = 0.0.obs; // meters
  var pace = 0.0.obs; // min/km
  
  // New States for Posting
  final title = TextEditingController();
  final description = TextEditingController();
  final isPublic = true.obs;
  final postRepo = Get.put(PostRepository());
  final userController = Get.put(UserController());

  var polylinePoints = <LatLng>[].obs;
  Timer? _timer;
  StreamSubscription<Position>? _positionStream;

  void startRecording() async {
    // Reset inputs
    title.clear();
    description.clear();
    isPublic.value = true;

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
    
    if (distance.value >= 10) { // Lưu nếu chạy trên 10m
      final workout = WorkoutModel(
        userId: userController.user.value.id ?? FirebaseAuth.instance.currentUser?.uid ?? "",
        type: "Running",
        distance: distance.value,
        duration: duration.value,
        averagePace: pace.value,
        timestamp: DateTime.now(),
        route: polylinePoints.map((p) => GeoPoint(p.latitude, p.longitude)).toList(),
        title: title.text.trim().isNotEmpty ? title.text.trim() : "Hoạt động chạy bộ",
        description: description.text.trim(),
      );
      
      // 1. Luôn lưu vào Workouts
      await _workoutRepo.saveWorkout(workout);

      // 2. Nếu isPublic = true, tạo bài đăng ở bảng Posts
      if (isPublic.value) {
        final post = PostModel(
          userId: userController.user.value.id ?? "",
          userName: userController.user.value.fullName ?? "",
          userProfilePicture: userController.user.value.profilePicture ?? "",
          title: title.text.trim().isNotEmpty ? title.text.trim() : "Chạy bộ",
          content: description.text.trim().isNotEmpty 
              ? description.text.trim() 
              : "Tôi vừa hoàn thành ${(distance.value / 1000).toStringAsFixed(2)}km!",
          imageUrl: "",
          createdAt: DateTime.now(),
        );
        await postRepo.createPost(post, null);
        
        if (Get.isRegistered<PostController>()) {
          PostController.instance.fetchPosts();
        }
      }
      Get.snackbar("Thành công", isPublic.value ? "Đã lưu và đăng hoạt động!" : "Đã lưu vào nhật ký!");
    } else {
      Get.snackbar("Thông báo", "Quãng đường quá ngắn để lưu.");
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
