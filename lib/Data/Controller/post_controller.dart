import 'package:runvix/export.dart';

class PostController extends GetxController {
  static PostController get instance => Get.find();

  final postRepo = Get.put(PostRepository());
  final userController = UserController.instance;

  final title = TextEditingController();
  final content = TextEditingController();
  
  // Variables for workout posts
  var workoutDistance = 0.0.obs;
  var workoutDuration = 0.obs;
  var workoutPace = 0.0.obs;
  var workoutImageUrl = "".obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final allPosts = <PostModel>[].obs;
  bool _hasMore = true;
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  // Tiện ích lấy User ID hiện tại
  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? userController.user.value.id;

  // Clear workout data
  void clearWorkoutData() {
    workoutDistance.value = 0.0;
    workoutDuration.value = 0;
    workoutPace.value = 0.0;
    workoutImageUrl.value = "";
    title.clear();
    content.clear();
  }

  // --- FETCHING LOGIC ---

  Future<void> fetchPosts() async {
    if (isLoading.value) return;
    _hasMore = true;
    _lastDocument = null;
    await _fetchPostsInternal(isLoadMore: false);
  }

  Future<void> loadMorePosts() async {
    if (isLoadingMore.value || !_hasMore || isLoading.value) return;
    await _fetchPostsInternal(isLoadMore: true);
  }

  Future<void> _fetchPostsInternal({required bool isLoadMore}) async {
    try {
      if (isLoadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }

      final result = await postRepo.getPaginatedPosts(_lastDocument, _limit, currentUserId: _currentUid);
      final List<PostModel> posts = result["posts"] ?? [];
      _lastDocument = result["lastDocument"];

      if (isLoadMore) {
        allPosts.addAll(posts);
      } else {
        if (posts.isEmpty) {
          _mockPosts();
        } else {
          allPosts.assignAll(posts);
        }
      }

      if (posts.length < _limit) {
        _hasMore = false;
      }
    } catch (e) {
      print("Error fetching posts: $e");
      if (!isLoadMore) _mockPosts();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void _mockPosts() {
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
  }


  Future<void> createPost(XFile? imageFile) async {
    try {
      isLoading.value = true;

      final post = PostModel(
        userId: userController.user.value.id ?? "",
        title: title.text.trim(),
        content: content.text.trim(),
        imageUrl: workoutImageUrl.value,
        distance: workoutDistance.value > 0 ? workoutDistance.value : null,
        duration: workoutDuration.value > 0 ? workoutDuration.value : null,
        averagePace: workoutPace.value > 0 ? workoutPace.value : null,
        type: workoutDistance.value > 0 ? "Running" : null,
      );

      await postRepo.createPost(post, imageFile);
      await fetchPosts();
      clearWorkoutData();

      Get.back(); 
      Get.snackbar("Thành công", "Bài viết của bạn đã được đăng!");
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

      int index = allPosts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        allPosts[index] = updatedPost;
      }

      Get.snackbar("Thành công", updatedPost.isLocked ? "Đã khóa bài viết" : "Đã mở khóa bài viết");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể thay đổi trạng thái bài viết: $e");
    }
  }


  Future<void> toggleLike(PostModel post) async {
    final uid = _currentUid;
    if (post.id == null || uid == null || uid.isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng đăng nhập để thực hiện tính năng này");
      return;
    }

    final postId = post.id!;
    int index = allPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final oldPost = allPosts[index];
    final newIsLiked = !oldPost.isLiked;
    final newLikesCount = newIsLiked ? oldPost.likes + 1 : oldPost.likes - 1;

    // Optimistic Update
    allPosts[index] = oldPost.copyWith(
      isLiked: newIsLiked,
      likes: newLikesCount < 0 ? 0 : newLikesCount,
    );

    try {
      await postRepo.likePost(postId, uid);
    } catch (e) {
      allPosts[index] = oldPost; // Rollback nếu lỗi
      Get.snackbar("Lỗi", "Không thể thực hiện like: $e");
    }
  }
}
