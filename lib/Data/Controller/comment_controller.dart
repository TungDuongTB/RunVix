import 'package:runvix/export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    final user = userController.user.value;
    final userId = user.id ?? "";
    if (userId.isEmpty) return;

    try {
      // Kiểm tra xem người dùng có bị cấm không
      final postSnap = await FirebaseFirestore.instance.collection("Posts").doc(postId).get();
      if (postSnap.exists) {
        final data = postSnap.data() ?? {};
        final banned = List<String>.from(data["BannedUsers"] ?? []);
        if (banned.contains(userId)) {
          Get.snackbar("Thông báo", "Bạn đã bị chủ bài viết cấm bình luận.");
          return;
        }
      }

      final newComment = CommentModel(
        postId: postId,
        userId: userId,
        userName: user.fullName ?? "Người dùng RunVix",
        userProfilePicture: user.profilePicture ?? "",
        comment: commentContent.text.trim(),
        createdAt: DateTime.now(),
      );

      await postRepo.addComment(newComment);

      // Cập nhật danh sách local
      comments.insert(0, newComment);
      commentContent.clear();
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể gửi bình luận: $e");
    }
  }

  Future<void> editComment(CommentModel comment, String newContent) async {
    if (newContent.trim().isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection("Comments")
          .doc(comment.id)
          .update({"Comment": newContent.trim()});
      
      final idx = comments.indexWhere((c) => c.id == comment.id);
      if (idx != -1) {
        comments[idx] = CommentModel(
          id: comment.id,
          postId: comment.postId,
          userId: comment.userId,
          userName: comment.userName,
          userProfilePicture: comment.userProfilePicture,
          comment: newContent.trim(),
          createdAt: comment.createdAt,
          isHidden: comment.isHidden,
        );
      }
      Get.snackbar("Thành công", "Đã cập nhật bình luận");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể sửa bình luận: $e");
    }
  }

  Future<void> deleteComment(CommentModel comment) async {
    try {
      await FirebaseFirestore.instance
          .collection("Comments")
          .doc(comment.id)
          .delete();
      
      await FirebaseFirestore.instance
          .collection("Posts")
          .doc(comment.postId)
          .update({"Comments": FieldValue.increment(-1)});

      comments.removeWhere((c) => c.id == comment.id);
      Get.snackbar("Thành công", "Đã xóa bình luận");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể xóa bình luận: $e");
    }
  }

  Future<void> hideComment(CommentModel comment) async {
    try {
      await FirebaseFirestore.instance
          .collection("Comments")
          .doc(comment.id)
          .update({"IsHidden": true});
      
      await FirebaseFirestore.instance
          .collection("Posts")
          .doc(comment.postId)
          .update({"Comments": FieldValue.increment(-1)});
      
      final idx = comments.indexWhere((c) => c.id == comment.id);
      if (idx != -1) {
        comments[idx] = CommentModel(
          id: comment.id,
          postId: comment.postId,
          userId: comment.userId,
          userName: comment.userName,
          userProfilePicture: comment.userProfilePicture,
          comment: comment.comment,
          createdAt: comment.createdAt,
          isHidden: true,
        );
      }
      Get.snackbar("Thành công", "Đã ẩn bình luận");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể ẩn bình luận: $e");
    }
  }

  Future<void> unhideComment(CommentModel comment) async {
    try {
      await FirebaseFirestore.instance
          .collection("Comments")
          .doc(comment.id)
          .update({"IsHidden": false});

      await FirebaseFirestore.instance
          .collection("Posts")
          .doc(comment.postId)
          .update({"Comments": FieldValue.increment(1)});

      final idx = comments.indexWhere((c) => c.id == comment.id);
      if (idx != -1) {
        comments[idx] = CommentModel(
          id: comment.id,
          postId: comment.postId,
          userId: comment.userId,
          userName: comment.userName,
          userProfilePicture: comment.userProfilePicture,
          comment: comment.comment,
          createdAt: comment.createdAt,
          isHidden: false,
        );
      }
      Get.snackbar("Thành công", "Đã gỡ ẩn bình luận");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể gỡ ẩn bình luận: $e");
    }
  }

  Future<void> banUser(String targetUserId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Posts")
          .doc(postId)
          .update({
            "BannedUsers": FieldValue.arrayUnion([targetUserId])
          });
      Get.snackbar("Thành công", "Đã cấm người dùng bình luận trên bài viết này");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cấm người dùng: $e");
    }
  }
}
