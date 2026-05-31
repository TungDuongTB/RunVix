import 'package:runvix/export.dart';

class PostController extends GetxController {
  static PostController get instance => Get.find();

  final postRepo = Get.put(PostRepository());
  final userController = UserController.instance;

  final title = TextEditingController();
  final content = TextEditingController();
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final allPosts = <PostModel>[].obs;
  
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  final int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPosts();
    });
  }

  Future<void> fetchPosts() async {
    if (isLoading.value) return;
    
    try {
      isLoading.value = true;
      _lastDocument = null;
      _hasMore = true;
      
      final result = await postRepo.getPaginatedPosts(null, _limit);
      final posts = result["posts"] as List<PostModel>;
      
      if (posts.isEmpty) {
        // Mock data bài viết nếu Firebase trống
        allPosts.assignAll([
          PostModel(
            id: "m1",
            userId: "1",
            userName: "Nguyễn Văn Kiên",
            userProfilePicture: "https://i.pravatar.cc/150?u=1",
            title: "Buổi sáng tuyệt vời",
            content: "Vừa hoàn thành 5km quanh Hồ Tây. Thời tiết thật mát mẻ!",
            imageUrl: "https://picsum.photos/id/10/800/600",
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          PostModel(
            id: "m2",
            userId: "2",
            userName: "Trần Minh Thư",
            userProfilePicture: "https://i.pravatar.cc/150?u=2",
            title: "Thử thách 10km",
            content: "Hôm nay mình đã phá kỷ lục cá nhân. Cố gắng lên mọi người!",
            imageUrl: "https://picsum.photos/id/20/800/600",
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ]);
        _hasMore = false;
      } else {
        _lastDocument = result["lastDocument"] as DocumentSnapshot?;
        allPosts.assignAll(posts);
        if (posts.length < _limit) {
          _hasMore = false;
        }
      }
    } catch (e) {
      print("Fetch Error: $e");
      // Fallback to mock on error
      _mockPosts();
    } finally {
      isLoading.value = false;
    }
  }

  void _mockPosts() {
    allPosts.assignAll([
      PostModel(
        id: "m1",
        userId: "1",
        userName: "Nguyễn Văn Kiên",
        userProfilePicture: "https://i.pravatar.cc/150?u=1",
        title: "Chạy bộ buổi sáng",
        content: "Khởi động ngày mới với 5km nhẹ nhàng.",
        imageUrl: "https://picsum.photos/id/30/800/600",
        createdAt: DateTime.now(),
      ),
    ]);
  }

  Future<void> loadMorePosts() async {
    // Ngăn chặn gọi đồng thời hoặc khi đang tải trang đầu, hoặc khi đã hết dữ liệu
    if (isLoading.value || isLoadingMore.value || !_hasMore || allPosts.isEmpty) return;

    try {
      isLoadingMore.value = true;
      final result = await postRepo.getPaginatedPosts(_lastDocument, _limit);
      final posts = result["posts"] as List<PostModel>;
      final newLastDoc = result["lastDocument"] as DocumentSnapshot?;
      
      if (posts.isEmpty) {
        _hasMore = false;
      } else {
        // Lọc bỏ bài viết trùng lặp dựa trên ID để tránh hiện tượng "loop" dữ liệu
        final existingIds = allPosts.map((p) => p.id).toSet();
        final uniqueNewPosts = posts.where((p) => !existingIds.contains(p.id)).toList();
        
        if (uniqueNewPosts.isNotEmpty) {
          allPosts.addAll(uniqueNewPosts);
          _lastDocument = newLastDoc;
        }

        if (posts.length < _limit) {
          _hasMore = false;
        }
      }
    } catch (e) {
      print("Error loading more: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Xóa hàm _getLastDocumentFromFirestore vì không còn cần thiết


  Future<void> createPost(XFile? imageFile) async {
    try {
      isLoading.value = true;

      final post = PostModel(
        userId: userController.user.value.id ?? "",
        title: title.text.trim(),
        content: content.text.trim(),
        imageUrl: "", 
      );

      await postRepo.createPost(post, imageFile);

      // Reset và tải lại dữ liệu mới nhất
      await fetchPosts();

      Get.back(); 
      Get.snackbar("Thành công", "Bài viết của bạn đã được đăng!");
      
      title.clear();
      content.clear();
    } catch (e) {
      Get.snackbar("Lỗi", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      isLoading.value = true;
      await postRepo.deletePost(postId);
      allPosts.removeWhere((p) => p.id == postId);
      Get.snackbar("Thành công", "Đã xóa bài viết");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể xóa bài viết: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePost(PostModel post) async {
    try {
      isLoading.value = true;
      await postRepo.updatePost(post);
      await fetchPosts();
      Get.snackbar("Thành công", "Đã cập nhật bài viết");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cập nhật bài viết: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLockPost(PostModel post) async {
    try {
      final updatedPost = post.copyWith(isLocked: !post.isLocked);
      await postRepo.updatePost(updatedPost);
      
      // Cập nhật local list để UI phản hồi ngay lập tức
      int index = allPosts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        allPosts[index] = updatedPost;
      }
      
      Get.snackbar("Thành công", updatedPost.isLocked ? "Đã khóa bài viết" : "Đã mở khóa bài viết");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể thay đổi trạng thái bài viết: $e");
    }
  }
}
