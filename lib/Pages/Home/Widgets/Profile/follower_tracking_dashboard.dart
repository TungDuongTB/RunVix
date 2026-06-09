import 'package:runvix/export.dart';

/// Tracking Dashboard - Monitor real-time followers changes
class FollowerTrackingDashboard extends StatefulWidget {
  const FollowerTrackingDashboard({super.key});

  @override
  State<FollowerTrackingDashboard> createState() => _FollowerTrackingDashboardState();
}

class _FollowerTrackingDashboardState extends State<FollowerTrackingDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final userController = UserController.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Theo dõi Real-time',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.buttonColor,
          tabs: [
            Obx(() => Tab(text: 'Người theo dõi (${userController.followerIds.length})')),
            Obx(() => Tab(text: 'Đang theo dõi (${userController.followingIds.length})')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FollowersTab(),
          _FollowingTab(),
        ],
      ),
    );
  }
}

class _FollowersTab extends StatefulWidget {
  const _FollowersTab();

  @override
  State<_FollowersTab> createState() => _FollowersTabState();
}

class _FollowersTabState extends State<_FollowersTab> {
  late final userController = UserController.instance;
  late final _userRepo = Get.put(UserRepository());
  final followerUsers = <UserModel>[].obs;
  final isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadFollowers();
    ever(userController.followerIds, (_) {
      _loadFollowers();
    });
  }

  Future<void> _loadFollowers() async {
    try {
      isLoading.value = true;
      final List<UserModel> users = [];
      for (var id in userController.followerIds) {
        final user = await _userRepo.getUserDetails(id);
        if (user.id!.isEmpty) users.add(user);
      }
      followerUsers.assignAll(users);
    } catch (e) {
      debugPrint('Error loading followers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
      }

      if (userController.followerIds.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Chưa có người theo dõi',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _loadFollowers,
        color: AppColors.buttonColor,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: followerUsers.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = followerUsers[index];
            return _buildUserTile(user, isFollower: true);
          },
        ),
      );
    });
  }

  Widget _buildUserTile(UserModel user, {required bool isFollower}) {
    return Obx(() {
      final isFollowingBack = userController.followingIds.contains(user.id);
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(user.profilePicture.isNotEmpty ? user.profilePicture : 'https://picsum.photos/200'),
        ),
        title: Text(
          user.fullName.isNotEmpty ? user.fullName : user.username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '@${user.username}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: isFollowingBack
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text('Theo dõi bạn', style: TextStyle(color: AppColors.buttonColor, fontSize: 11, fontWeight: FontWeight.w500)),
              )
            : ElevatedButton(
                onPressed: () => userController.toggleFollowUser(user.id ?? ""),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                child: const Text('Theo dõi lại', style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
      );
    });
  }
}

class _FollowingTab extends StatefulWidget {
  const _FollowingTab();

  @override
  State<_FollowingTab> createState() => _FollowingTabState();
}

class _FollowingTabState extends State<_FollowingTab> {
  late final userController = UserController.instance;
  late final _userRepo = Get.put(UserRepository());
  final followingUsers = <UserModel>[].obs;
  final isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
    ever(userController.followingIds, (_) {
      _loadFollowing();
    });
  }

  Future<void> _loadFollowing() async {
    try {
      isLoading.value = true;
      final List<UserModel> users = [];
      for (var id in userController.followingIds) {
        final user = await _userRepo.getUserDetails(id);
        if (user.id!.isNotEmpty) users.add(user);
      }
      followingUsers.assignAll(users);
    } catch (e) {
      debugPrint('Error loading following: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
      }

      if (userController.followingIds.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Bạn chưa theo dõi ai',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _loadFollowing,
        color: AppColors.buttonColor,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: followingUsers.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = followingUsers[index];
            return _buildUserTile(user);
          },
        ),
      );
    });
  }

  Widget _buildUserTile(UserModel user) {
    return Obx(() {
      final isFollower = userController.followerIds.contains(user.id);
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(user.profilePicture.isNotEmpty ? user.profilePicture : 'https://picsum.photos/200'),
        ),
        title: Text(
          user.fullName.isNotEmpty ? user.fullName : user.username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${user.username}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (isFollower)
              const Text('Theo dõi bạn', style: TextStyle(color: AppColors.buttonColor, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
        trailing: TextButton(
          onPressed: () => userController.toggleFollowUser(user.id ?? ""),
          child: const Text('Bỏ', style: TextStyle(color: Colors.red, fontSize: 12)),
        ),
      );
    });
  }
}


