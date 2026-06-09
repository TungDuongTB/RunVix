import 'package:runvix/export.dart';

class ProfileHubScreen extends StatefulWidget {
  final String? userId;

  const ProfileHubScreen({super.key, this.userId});

  @override
  State<ProfileHubScreen> createState() => _ProfileHubScreenState();
}

class _ProfileHubScreenState extends State<ProfileHubScreen> {
  UserModel? targetUser;
  List<PostModel> userPosts = [];
  int followingCount = 0;
  int followersCount = 0;
  int totalLikesCount = 0;
  bool isLoading = true;

  StreamSubscription? _profileFollowingSubscription;
  StreamSubscription? _profileFollowerSubscription;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _profileFollowingSubscription?.cancel();
    _profileFollowerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final String? targetUid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (targetUid == null || targetUid.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // 1. Fetch user model details
      final userRepo = UserRepository.instance;
      final user = await userRepo.getUserDetails(targetUid);

      // 2. Fetch user's posts
      final db = FirebaseFirestore.instance;
      final postsSnapshot = await db
          .collection("Posts")
          .where("UserId", isEqualTo: targetUid)
          .get();

      List<PostModel> posts = postsSnapshot.docs
          .map((doc) => PostModel.fromSnapshot(
                doc as DocumentSnapshot<Map<String, dynamic>>,
                userName: user.fullName,
                userProfilePicture: user.profilePicture,
              ))
          .toList();

      // Sắp xếp các bài viết mới nhất lên đầu (createdAt giảm dần)
      posts.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      // Calculate total likes of all posts of this user
      int likesSum = 0;
      for (var p in posts) {
        likesSum += p.likes;
      }

      // 3. Set up real-time followers/following stream listeners
      _listenToTargetFollowStreams(targetUid);

      setState(() {
        targetUser = user;
        userPosts = posts;
        totalLikesCount = likesSum;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading profile: $e");
      setState(() {
        isLoading = false;
      });
      Get.snackbar("Lỗi", "Không thể tải thông tin hồ sơ: $e");
    }
  }

  void _listenToTargetFollowStreams(String targetUid) {
    _profileFollowingSubscription?.cancel();
    _profileFollowerSubscription?.cancel();

    final userRepo = UserRepository.instance;

    _profileFollowingSubscription = userRepo.getFollowingStream(targetUid).listen((ids) {
      if (mounted) {
        setState(() {
          followingCount = ids.length;
        });
      }
    });

    _profileFollowerSubscription = userRepo.getFollowerStream(targetUid).listen((ids) {
      if (mounted) {
        setState(() {
          followersCount = ids.length;
        });
      }
    });
  }

  Future<void> _toggleFollow() async {
    final targetUid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (targetUid == null || targetUid == FirebaseAuth.instance.currentUser?.uid) return;

    await UserController.instance.toggleFollowUser(targetUid);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (targetUser == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () => Get.back(),
          ),
          title: const Text('Lỗi', style: TextStyle(color: Colors.black)),
        ),
        body: const Center(
          child: Text('Không tìm thấy người dùng'),
        ),
      );
    }

    // Lấy danh sách ảnh từ các bài đăng
    final List<String> postImages = userPosts
        .map((p) => p.imageUrl)
        .where((url) => url.isNotEmpty)
        .toList();

    final isCurrentUser = widget.userId == null || widget.userId == FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Use ProfileHeaderComponent wrapped with Obx for real-time updates
              Obx(() {
                final userController = UserController.instance;
                final targetUid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;

                // Real-time mutual follow checks
                final bool realTimeIsFollowing = userController.followingIds.contains(targetUid);
                final bool realTimeIsFollower = userController.followerIds.contains(targetUid);

                return ProfileHeaderComponent(
                  avatarUrl: targetUser!.profilePicture.isNotEmpty ? targetUser!.profilePicture : 'https://picsum.photos/200',
                  fullName: targetUser!.fullName.isNotEmpty ? targetUser!.fullName : 'Người dùng RunVix',
                  subtitle: targetUser!.username.isNotEmpty ? '@${targetUser!.username}' : targetUser!.email,
                  bio: targetUser!.bio.isNotEmpty ? targetUser!.bio : 'Chưa có giới thiệu',
                  following: followingCount,
                  followers: followersCount,
                  likes: totalLikesCount,
                  isFollowing: realTimeIsFollowing,
                  isFollower: realTimeIsFollower,
                  onFollowPressed: isCurrentUser ? null : _toggleFollow,
                  onStatTap: () {
                    // Handle stat tap
                  },
                );
              }),

              const SizedBox(height: 24),

              // Use ProfilePostGridComponent
              ProfilePostGridComponent(
                postImages: postImages,
                title: 'Bài đăng (${postImages.length})',
                crossAxisCount: 3,
                spacing: 8.0,
                onPostTap: () {
                  // Handle post tap - mở ảnh full screen
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== AppBar =====
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Hồ sơ',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.ios_share, color: Colors.black, size: 22),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black, size: 22),
          onPressed: () {},
        ),
      ],
    );
  }
}
