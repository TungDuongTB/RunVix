import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class AdminContentPanel extends StatefulWidget {
  const AdminContentPanel({super.key});

  @override
  State<AdminContentPanel> createState() => _AdminContentPanelState();
}

class _AdminContentPanelState extends State<AdminContentPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final postController = Get.find<PostController>();
  String _searchQuery = "";
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.buttonColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.buttonColor,
                  tabs: const [
                    Tab(text: "Bài viết"),
                    Tab(text: "Bài tập"),
                    Tab(text: "Thử thách"),
                    Tab(text: "Tuyến đường"),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm nhanh...",
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostList(),
                _buildWorkoutList(),
                _buildChallengeList(),
                _buildRouteList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Duyệt & Điều phối hoạt động", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showWorkoutForm(),
              icon: const Icon(Icons.add),
              label: const Text("Thêm bài tập mẫu"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              final title = "Chạy bộ buổi sáng #$index";
              if (_searchQuery.isNotEmpty && !title.toLowerCase().contains(_searchQuery.toLowerCase())) return const SizedBox();
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.directions_run, color: Colors.white)),
                  title: Text(title),
                  subtitle: const Text("Người dùng: Nguyen Van A • Trạng thái: Chờ duyệt"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check_circle_outline, color: Colors.green), onPressed: () {}, tooltip: "Duyệt"),
                      IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showWorkoutForm()),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () {}),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Quản lý thử thách cộng đồng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showChallengeForm(),
              icon: const Icon(Icons.add),
              label: const Text("Tạo thử thách"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Reponsive.isDesktop(context) ? 3 : 1,
              childAspectRatio: 2.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final title = "Thử thách RunVix ${index + 1}";
              if (_searchQuery.isNotEmpty && !title.toLowerCase().contains(_searchQuery.toLowerCase())) return const SizedBox();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.emoji_events, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const Text("Mục tiêu: 50km chạy bộ", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _showChallengeForm()),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () {}),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRouteList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Điều phối tuyến đường gợi ý", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showRouteForm(),
              icon: const Icon(Icons.add),
              label: const Text("Thêm tuyến đường"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              final title = "Cung đường Hồ Tây #$index";
              if (_searchQuery.isNotEmpty && !title.toLowerCase().contains(_searchQuery.toLowerCase())) return const SizedBox();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.map, color: Colors.green),
                  title: Text(title),
                  subtitle: const Text("15km • Độ khó: Trung bình"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showRouteForm()),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () {}),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showWorkoutForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thông tin Bài tập / Hoạt động"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(decoration: InputDecoration(labelText: "Tên hoạt động")),
              TextField(decoration: InputDecoration(labelText: "Loại (Chạy bộ, Đạp xe...)")),
              TextField(decoration: InputDecoration(labelText: "Khoảng cách (km)")),
              TextField(decoration: InputDecoration(labelText: "Mô tả")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Lưu")),
        ],
      ),
    );
  }

  void _showChallengeForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tạo thử thách mới"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(decoration: InputDecoration(labelText: "Tên thử thách")),
              TextField(decoration: InputDecoration(labelText: "Mục tiêu (Số km)")),
              TextField(decoration: InputDecoration(labelText: "Ngày bắt đầu")),
              TextField(decoration: InputDecoration(labelText: "Ngày kết thúc")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Tạo ngay")),
        ],
      ),
    );
  }

  void _showRouteForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thông tin tuyến đường"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(decoration: InputDecoration(labelText: "Tên tuyến đường")),
              TextField(decoration: InputDecoration(labelText: "Chiều dài (km)")),
              TextField(decoration: InputDecoration(labelText: "Điểm bắt đầu - Kết thúc")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Lưu")),
        ],
      ),
    );
  }

  Widget _buildPostList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Quản lý bài viết cộng đồng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showPostForm(),
              icon: const Icon(Icons.add),
              label: const Text("Tạo bài viết"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (postController.isLoading.value && postController.allPosts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final posts = postController.allPosts.where((post) {
              return _searchQuery.isEmpty ||
                  post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  post.userName.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            if (posts.isEmpty) {
              return const Center(child: Text("Không tìm thấy bài viết nào"));
            }

            return RefreshIndicator(
              onRefresh: () => postController.fetchPosts(),
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: post.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(post.imageUrl,
                                  width: 50, height: 50, fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.broken_image)),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.orangeAccent,
                              child: Icon(Icons.article, color: Colors.white)),
                      title: Text(post.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                          "Tác giả: ${post.userName} • ${post.createdAt != null ? post.createdAt!.toString().substring(0, 10) : 'N/A'}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.blue),
                              onPressed: () => _showPostForm(post: post)),
                          IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _confirmDelete(post.id!)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _confirmDelete(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa bài viết này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              postController.deletePost(postId);
              Navigator.pop(context);
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  void _showPostForm({PostModel? post}) {
    if (post != null) {
      postController.title.text = post.title;
      postController.content.text = post.content;
    } else {
      postController.title.clear();
      postController.content.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(post == null ? "Tạo bài viết mới" : "Chỉnh sửa bài viết"),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: postController.title,
                    decoration: const InputDecoration(labelText: "Tiêu đề bài viết")),
                const SizedBox(height: 16),
                TextField(
                    controller: postController.content,
                    decoration: const InputDecoration(labelText: "Nội dung"),
                    maxLines: 10),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy")),
          ElevatedButton(
              onPressed: () {
                if (post == null) {
                  postController.createPost(null);
                } else {
                  final updatedPost = PostModel(
                    id: post.id,
                    userId: post.userId,
                    userName: post.userName,
                    userProfilePicture: post.userProfilePicture,
                    title: postController.title.text.trim(),
                    content: postController.content.text.trim(),
                    imageUrl: post.imageUrl,
                    createdAt: post.createdAt,
                    likes: post.likes,
                    comments: post.comments,
                  );
                  postController.updatePost(updatedPost);
                }
                Navigator.pop(context);
              },
              child: const Text("Lưu")),
        ],
      ),
    );
  }
}
