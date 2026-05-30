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
      _lastDocument = result["lastDocument"] as DocumentSnapshot?;
      
      allPosts.assignAll(posts);
      
      if (posts.length < _limit) {
        _hasMore = false;
      }
    } catch (e) {
      print("Fetch Error: $e");
      Get.snackbar("Lỗi", "Không thể tải bài viết");
    } finally {
      isLoading.value = false;
    }
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
}
