import 'package:runvix/export.dart';

class ManualActivityController extends GetxController {
  static ManualActivityController get instance => Get.find();

  final workoutRepo = WorkoutRepository.instance;
  final postRepo = PostRepository.instance; // For image upload
  final userController = UserController.instance;

  final title = TextEditingController(text: "Chạy bộ buổi chiều");
  final description = TextEditingController();
  
  final selectedType = "Chạy bộ".obs;
  final selectedDateTime = DateTime.now().obs;
  
  final hours = 0.obs;
  final minutes = 0.obs;
  final seconds = 0.obs;
  
  final distance = 0.0.obs;
  
  final selectedImage = Rx<XFile?>(null);
  final isPublic = true.obs; // Mặc định là đăng lên Feed
  final isLoading = false.obs;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = image;
    }
  }

  Future<void> saveActivity() async {
    try {
      if (distance.value <= 0 && hours.value == 0 && minutes.value == 0 && seconds.value == 0) {
        Get.snackbar("Thông báo", "Vui lòng nhập thông tin hoạt động");
        return;
      }

      isLoading.value = true;

      String imageUrl = "";
      if (selectedImage.value != null) {
        imageUrl = await postRepo.uploadImage(selectedImage.value!);
      }

      int totalSeconds = (hours.value * 3600) + (minutes.value * 60) + seconds.value;
      double avgPace = 0;
      if (distance.value > 0 && totalSeconds > 0) {
        avgPace = (totalSeconds / 60) / distance.value;
      }

      final workout = WorkoutModel(
        userId: userController.user.value.id ?? "",
        type: selectedType.value,
        distance: distance.value * 1000,
        duration: totalSeconds,
        averagePace: avgPace,
        timestamp: selectedDateTime.value,
        route: [],
        title: title.text.trim(),
        description: description.text.trim(),
        imageUrl: imageUrl,
      );

      // 1. Lưu vào bảng Workouts (Luôn lưu vào lịch sử cá nhân)
      await workoutRepo.saveWorkout(workout);

      // 2. Nếu người dùng chọn "Đăng", tạo một bản ghi ở bảng Posts
      if (isPublic.value) {
        final post = PostModel(
          userId: userController.user.value.id ?? "",
          userName: userController.user.value.fullName ?? "",
          userProfilePicture: userController.user.value.profilePicture ?? "",
          title: title.text.trim(),
          content: description.text.trim().isNotEmpty 
              ? description.text.trim() 
              : "Đã hoàn thành buổi ${selectedType.value.toLowerCase()} ${distance.value}km!",
          imageUrl: imageUrl,
          createdAt: DateTime.now(),
          distance: distance.value,
          duration: totalSeconds,
          averagePace: avgPace,
          type: selectedType.value,
        );
        
        // Gọi repo để tạo bài đăng
        await postRepo.createPost(post, null); // Ảnh đã upload ở trên rồi nên truyền null
        
        // Cập nhật lại danh sách bài viết ở trang chủ
        if (Get.isRegistered<PostController>()) {
          PostController.instance.fetchPosts();
        }
      }
      // Refresh calendar/streak
      try {
        if (Get.isRegistered<CalendarController>()) {
          CalendarController.instance.fetchCurrentWeekEvents();
        }
      } catch (e) {}

      Get.back();
      Get.snackbar("Thành công", isPublic.value ? "Đã lưu và đăng hoạt động!" : "Đã lưu vào nhật ký hoạt động!");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể thực hiện: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime.value),
      );
      if (pickedTime != null) {
        selectedDateTime.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  void setDuration(int h, int m, int s) {
    hours.value = h;
    minutes.value = m;
    seconds.value = s;
  }

  void setDistance(double d) {
    distance.value = d;
  }
}
