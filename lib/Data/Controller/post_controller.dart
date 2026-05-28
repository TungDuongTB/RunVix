import 'package:runvix/export.dart';

class PostController extends GetxController {
  static PostController get instance => Get.find();

  final postRepo = Get.put(PostRepository());
  final userController = UserController.instance;

  final title = TextEditingController();
  final content = TextEditingController();
  final isLoading = false.obs;

  Future<void> createPost(XFile? imageFile) async {
    try {
      // 1. Kiểm tra quyền (Chỉ Điều phối viên hoặc Admin mới được đăng bài)
      if (!userController.user.value.isCoordinator && !userController.user.value.isAdmin) {
        Get.snackbar("Thông báo", "Bạn không có quyền thực hiện chức năng này.");
        return;
      }

      // 2. Kiểm tra dữ liệu đầu vào
      if (title.text.trim().isEmpty || content.text.trim().isEmpty) {
        Get.snackbar("Thông báo", "Vui lòng nhập tiêu đề và nội dung");
        return;
      }

      if (imageFile == null) {
        Get.snackbar("Thông báo", "Vui lòng chọn ảnh cho bài viết");
        return;
      }

      isLoading.value = true;

      final post = PostModel(
        userId: userController.user.value.id ?? "",
        userName: userController.user.value.fullName,
        userProfilePicture: userController.user.value.profilePicture,
        title: title.text.trim(),
        content: content.text.trim(),
        imageUrl: "", // Sẽ được cập nhật trong repository
      );

      await postRepo.createPost(post, imageFile);

      Get.back(); // Quay lại màn hình trước
      Get.snackbar("Thành công", "Bài viết của bạn đã được đăng!");
      
      // Clear inputs
      title.clear();
      content.clear();
    } catch (e) {
      Get.snackbar("Lỗi", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
