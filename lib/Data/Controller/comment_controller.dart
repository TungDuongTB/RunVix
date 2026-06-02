import 'package:runvix/export.dart';

class CommentController extends GetxController {
  final String postId;
  CommentController({required this.postId});

  final postRepo = PostRepository.instance;
  final userController = UserController.instance;
  
  final commentContent = TextEditingController();
  final isLoading = false.obs;
  final comments = <CommentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchComments();
  }

  Future<void> fetchComments() async {
    try {
      isLoading.value = true;
      final fetchedComments = await postRepo.getComments(postId);
      comments.assignAll(fetchedComments);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải bình luận: $e");
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> sendComment() async {
    if (commentContent.text.trim().isEmpty) return;

    try {
      final user = userController.user.value;
      final newComment = CommentModel(
        postId: postId,
        userId: user.id ?? "",
        userName: user.fullName ?? "Người dùng RunVix",
        userProfilePicture: user.profilePicture ?? "",
        comment: commentContent.text.trim(),
        createdAt: DateTime.now(),
      );

      await postRepo.addComment(newComment);
      
      // Update local list
      comments.insert(0, newComment);
      commentContent.clear();
      
      // Update comment count in PostController if possible
      try {
        final postController = PostController.instance;
        int index = postController.allPosts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = postController.allPosts[index];
          postController.allPosts[index] = post.copyWith(comments: post.comments + 1);
        }
      } catch (_) {}

    } catch (e) {
      Get.snackbar("Lỗi", "Không thể gửi bình luận: $e");
    }
  }
}
