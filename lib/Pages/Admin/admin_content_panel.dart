import 'package:runvix/export.dart';

class AdminContentPanel extends StatefulWidget {
  const AdminContentPanel({super.key});

  @override
  State<AdminContentPanel> createState() => _AdminContentPanelState();
}

class _AdminContentPanelState extends State<AdminContentPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final postController = Get.find<PostController>();
  final reportController = Get.find<ReportController>();
  String _searchQuery = "";
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isSearchExpanded ? (Reponsive.isMobile(context) ? 180 : 300) : 40,
                child: _isSearchExpanded
                    ? TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm...",
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _isSearchExpanded = false;
                                _searchController.clear();
                                _searchQuery = "";
                              });
                            },
                          ),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search, color: AppColors.buttonColor),
                        onPressed: () {
                          setState(() {
                            _isSearchExpanded = true;
                          });
                          Future.delayed(Duration.zero, () => _searchFocusNode.requestFocus());
                        },
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
            const Expanded(
              child: Text("Duyệt & Điều phối hoạt động", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showWorkoutForm(),
              icon: const Icon(Icons.add),
              label: Text(Reponsive.isMobile(context) ? "Thêm" : "Thêm bài tập mẫu"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Builder(
            builder: (context) {
              final workouts = List.generate(5, (index) => "Chạy bộ buổi sáng #$index");
              final filteredWorkouts = workouts.where((w) => _searchQuery.isEmpty || w.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              
              if (filteredWorkouts.isEmpty) return const Center(child: Text("Không tìm thấy bài tập nào"));

              return ListView.builder(
                itemCount: filteredWorkouts.length,
                itemBuilder: (context, index) {
                  final title = filteredWorkouts[index];
                  
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
              );
            }
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
            const Expanded(
              child: Text("Quản lý thử thách cộng đồng", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showChallengeForm(),
              icon: const Icon(Icons.add),
              label: Text(Reponsive.isMobile(context) ? "Tạo" : "Tạo thử thách"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Builder(
            builder: (context) {
              final challenges = List.generate(4, (index) => "Thử thách RunVix ${index + 1}");
              final filteredChallenges = challenges.where((c) => _searchQuery.isEmpty || c.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

              if (filteredChallenges.isEmpty) return const Center(child: Text("Không tìm thấy thử thách nào"));

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Reponsive.isDesktop(context) ? 3 : (Reponsive.isTablet(context) ? 2 : 1),
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredChallenges.length,
                itemBuilder: (context, index) {
                  final title = filteredChallenges[index];

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
              );
            }
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
            const Expanded(
              child: Text("Điều phối tuyến đường gợi ý", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showRouteForm(),
              icon: const Icon(Icons.add),
              label: Text(Reponsive.isMobile(context) ? "Thêm" : "Thêm tuyến đường"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Builder(
            builder: (context) {
              final routes = List.generate(3, (index) => "Cung đường Hồ Tây #$index");
              final filteredRoutes = routes.where((r) => _searchQuery.isEmpty || r.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

              if (filteredRoutes.isEmpty) return const Center(child: Text("Không tìm thấy tuyến đường nào"));

              return ListView.builder(
                itemCount: filteredRoutes.length,
                itemBuilder: (context, index) {
                  final title = filteredRoutes[index];

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
              );
            }
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
            const Expanded(
              child: Text("Quản lý bài viết cộng đồng",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showPostForm(),
              icon: const Icon(Icons.add),
              label: Text(Reponsive.isMobile(context) ? "Tạo" : "Tạo bài viết"),
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
              onRefresh: () async {
                await postController.fetchPosts();
                await reportController.fetchAllReports();
              },
              child: ListView.builder(
                itemCount: posts.length,
                  itemBuilder: (context, index) {
                  final post = posts[index];
                  // Đếm số lượng báo cáo từ danh sách allReports của reportController
                  final reportsCount = reportController.allReports
                      .where((r) => r.postId == post.id)
                      .length;

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
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(post.title,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          if (reportsCount > 0)
                            GestureDetector(
                              onTap: () => _showReportsList(post.id!),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(12)),
                                child: Text("$reportsCount Báo cáo", style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          if (post.isLocked)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.lock, color: Colors.red, size: 16),
                            ),
                        ],
                      ),
                      subtitle: Text(
                          "Tác giả: ${post.userName} • ${post.createdAt != null ? post.createdAt!.toString().substring(0, 10) : 'N/A'}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.green),
                              onPressed: () => _viewPostDetail(post),
                              tooltip: "Xem chi tiết"),
                          IconButton(
                              icon: Icon(
                                  post.isLocked ? Icons.lock_open : Icons.lock_outline,
                                  color: post.isLocked ? Colors.orange : Colors.grey),
                              onPressed: () => postController.toggleLockPost(post),
                              tooltip: post.isLocked ? "Mở khóa" : "Khóa bài viết"),
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

  void _viewPostDetail(PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.article, color: AppColors.buttonColor),
            const SizedBox(width: 10),
            Expanded(child: Text(post.title)),
            if (post.isLocked) const Icon(Icons.lock, color: Colors.red),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (post.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(post.imageUrl, width: double.infinity, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: post.userProfilePicture.isNotEmpty ? NetworkImage(post.userProfilePicture) : null,
                      child: post.userProfilePicture.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(post.createdAt?.toString() ?? "N/A", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text("${post.likes} Likes", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Builder(
                          builder: (context) {
                            final reportsCount = reportController.allReports
                                .where((r) => r.postId == post.id)
                                .length;
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _showReportsList(post.id!);
                              },
                              child: Text("$reportsCount Báo cáo", 
                                style: TextStyle(
                                  color: reportsCount > 0 ? Colors.red : Colors.grey, 
                                  decoration: reportsCount > 0 ? TextDecoration.underline : null
                                )
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
                const Text("Nội dung:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(post.content),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
          if (!post.isLocked)
            ElevatedButton.icon(
              onPressed: () {
                postController.toggleLockPost(post);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.lock),
              label: const Text("Khóa bài"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            )
          else
             ElevatedButton.icon(
              onPressed: () {
                postController.toggleLockPost(post);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.lock_open),
              label: const Text("Mở khóa"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(post.id!);
            },
            icon: const Icon(Icons.delete),
            label: const Text("Xóa bài viết"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showReportsList(String postId) {
    reportController.fetchReportsByPost(postId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Danh sách báo cáo vi phạm"),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Obx(() {
            if (reportController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (reportController.reports.isEmpty) {
              return const Center(child: Text("Không có báo cáo nào"));
            }
            return ListView.builder(
              itemCount: reportController.reports.length,
              itemBuilder: (context, index) {
                final report = reportController.reports[index];
                return Card(
                  child: ListTile(
                    title: Text(report.reason),
                    subtitle: Text("Từ: ${report.reporterName} • ${report.createdAt?.toString().substring(0, 16) ?? ''}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      onPressed: () => reportController.resolveReport(report.id!, postId),
                      tooltip: "Đã xử lý / Bác bỏ",
                    ),
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
        ],
      ),
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
