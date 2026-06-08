import 'package:runvix/export.dart';

class RecordController extends GetxController {
  static RecordController get instance => Get.find();

  final _workoutRepo = Get.find<WorkoutRepository>();
  final _postRepo = Get.find<PostRepository>();
  final _userController = UserController.instance;
  
  // Input Controllers
  final title = TextEditingController();
  final description = TextEditingController();
  var isPublic = true.obs;

  // States
  var isRecording = false.obs;
  var isPaused = false.obs;
  var duration = 0.obs; // seconds
  var distance = 0.0.obs; // meters
  var pace = 0.0.obs; // min/km
  
  // Map States
  GoogleMapController? mapController;
  var currentPosition = Rxn<Position>();
  var polylinePoints = <LatLng>[].obs;

  // Private members
  Timer? _timer;
  StreamSubscription<Position>? _positionStream;
  
  // Computed polylines for the map
  Set<Polyline> get polylines => {
    Polyline(
      polylineId: const PolylineId('record_path'),
      points: polylinePoints.toList(),
      color: Colors.blue,
      width: 5,
    ),
  };

  @override
  void onInit() {
    super.onInit();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    currentPosition.value = position;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
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
      currentPosition.value = position; // Cập nhật vị trí hiện tại

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

        // Tự động di chuyển camera theo người dùng
        mapController?.animateCamera(
          CameraUpdate.newLatLng(newPoint),
        );
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
        userId: _userController.user.value.id ?? FirebaseAuth.instance.currentUser?.uid ?? "",
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
        // Generate Static Map URL
        String staticMapUrl = "";
        if (polylinePoints.isNotEmpty) {
          const apiKey = "AIzaSyBjd9_rTIEGk3sS0rE-7RdKq9WyAkKX-EI";
          
          // Tối ưu danh sách điểm (tối đa 80 điểm để URL không quá dài)
          List<LatLng> points = List.from(polylinePoints);
          if (points.length > 80) {
            int step = points.length ~/ 80;
            points = List.generate(80, (i) => points[i * step]);
            if (!points.contains(polylinePoints.last)) points.add(polylinePoints.last);
          }
          
          // Tạo chuỗi tọa độ cho path (định dạng: lat,lng)
          String pathParams = "color:0xff4b2cff|weight:5";
          for (var p in points) {
            pathParams += "|${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)}";
          }
          
          // Thêm Marker cho điểm bắt đầu (xanh) và kết thúc (đỏ)
          String markers = "&markers=color:green|label:S|${polylinePoints.first.latitude},${polylinePoints.first.longitude}";
          markers += "&markers=color:red|label:F|${polylinePoints.last.latitude},${polylinePoints.last.longitude}";

          staticMapUrl = "https://maps.googleapis.com/maps/api/staticmap?"
              "size=600x400"
              "&scale=2"
              "&maptype=roadmap"
              "&path=$pathParams"
              "$markers"
              "&key=$apiKey";
        }

        final post = PostModel(
          userId: _userController.user.value.id ?? "",
          userName: _userController.user.value.fullName ?? "",
          userProfilePicture: _userController.user.value.profilePicture ?? "",
          title: title.text.trim().isNotEmpty ? title.text.trim() : "Chạy bộ",
          content: description.text.trim().isNotEmpty 
              ? description.text.trim() 
              : "Tôi vừa hoàn thành ${(distance.value / 1000).toStringAsFixed(2)}km!",
          imageUrl: staticMapUrl,
          createdAt: DateTime.now(),
          distance: distance.value / 1000,
          duration: duration.value,
          averagePace: pace.value,
          type: "Running",
        );
        await _postRepo.createPost(post, null);
        
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
