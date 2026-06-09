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
  int streakCount = 0;
  double totalDistance = 0.0;
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
      final String? targetUid =
          widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
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
          .map(
            (doc) => PostModel.fromSnapshot(
              doc as DocumentSnapshot<Map<String, dynamic>>,
              userName: user.fullName,
              userProfilePicture: user.profilePicture,
            ),
          )
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

      // 3. Fetch workouts for the target user to compute total distance & streak
      final workoutRepo = WorkoutRepository.instance;
      final workouts = await workoutRepo.getUserWorkouts(targetUid);

      double totalDist = 0;
      final Set<DateTime> workoutDates = {};
      for (var w in workouts) {
        totalDist += w.distance;
        DateTime dayOnly = DateTime(
          w.timestamp.year,
          w.timestamp.month,
          w.timestamp.day,
        );
        workoutDates.add(dayOnly);
      }

      // Calculate streak based on workoutDates
      int streak = 0;
      if (workoutDates.isNotEmpty) {
        DateTime today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        DateTime yesterday = today.subtract(const Duration(days: 1));
        bool activeToday = workoutDates.contains(today);
        bool activeYesterday = workoutDates.contains(yesterday);

        if (activeToday || activeYesterday) {
          DateTime checkDate = activeToday ? today : yesterday;
          while (workoutDates.contains(checkDate)) {
            streak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
          }
        }
      }

      // 4. Set up real-time followers/following stream listeners
      _listenToTargetFollowStreams(targetUid);

      setState(() {
        targetUser = user;
        userPosts = posts;
        totalLikesCount = likesSum;
        totalDistance = totalDist / 1000.0;
        streakCount = streak;
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

    _profileFollowingSubscription = userRepo
        .getFollowingStream(targetUid)
        .listen((ids) {
          if (mounted) {
            setState(() {
              followingCount = ids.length;
            });
          }
        });

    _profileFollowerSubscription = userRepo.getFollowerStream(targetUid).listen(
      (ids) {
        if (mounted) {
          setState(() {
            followersCount = ids.length;
          });
        }
      },
    );
  }

  Future<void> _toggleFollow() async {
    final targetUid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (targetUid == null ||
        targetUid == FirebaseAuth.instance.currentUser?.uid)
      return;

    await UserController.instance.toggleFollowUser(targetUid);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (targetUser == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: const Text('Lỗi', style: TextStyle(color: Colors.black)),
        ),
        body: const Center(child: Text('Không tìm thấy người dùng')),
      );
    }

    // Lấy danh sách ảnh từ các bài đăng
    final List<String> postImages = userPosts
        .map((p) => p.imageUrl)
        .where((url) => url.isNotEmpty)
        .toList();

    final isCurrentUser =
        widget.userId == null ||
        widget.userId == FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
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
                final targetUid =
                    widget.userId ?? FirebaseAuth.instance.currentUser?.uid;

                // Real-time mutual follow checks
                final bool realTimeIsFollowing = userController.followingIds
                    .contains(targetUid);
                final bool realTimeIsFollower = userController.followerIds
                    .contains(targetUid);

                return ProfileHeaderComponent(
                  avatarUrl: targetUser!.profilePicture.isNotEmpty
                      ? targetUser!.profilePicture
                      : 'https://picsum.photos/200',
                  fullName: targetUser!.fullName.isNotEmpty
                      ? targetUser!.fullName
                      : 'Người dùng RunVix',
                  subtitle: targetUser!.username.isNotEmpty
                      ? '@${targetUser!.username}'
                      : targetUser!.email,
                  bio: targetUser!.bio.isNotEmpty
                      ? targetUser!.bio
                      : 'Chưa có giới thiệu',
                  following: followingCount,
                  followers: followersCount,
                  likes: totalLikesCount,
                  streakCount: streakCount,
                  totalDistance: totalDistance,
                  isFollowing: realTimeIsFollowing,
                  isFollower: realTimeIsFollower,
                  onFollowPressed: isCurrentUser ? null : _toggleFollow,
                  onStatTap: () {
                    // Handle stat tap
                  },
                );
              }),

              const SizedBox(height: 16),

              if (postImages.isEmpty)
                const ProfileHubEmptyState()
              else
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
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.buttonColor,
          size: 24,
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(
          color: AppColors.buttonColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
      centerTitle: true,
      actions: const [
        SizedBox(width: 40), // Balances the leading arrow_back
      ],
    );
  }
}
