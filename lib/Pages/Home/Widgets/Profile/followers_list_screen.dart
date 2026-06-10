import 'package:runvix/export.dart';

class FollowersListScreen extends StatefulWidget {
  final String? userId;

  const FollowersListScreen({super.key, this.userId});

  @override
  State<FollowersListScreen> createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends State<FollowersListScreen> {
  late final userController = UserController.instance;
  late final _userRepo = Get.put(UserRepository());
  final followerUsers = <UserModel>[].obs;
  final isLoadingFollowers = false.obs;

  @override
  void initState() {
    super.initState();
    _loadFollowerDetails();
    // Lắng nghe follower IDs real-time
    ever(userController.followerIds, (_) {
      _loadFollowerDetails();
    });
  }

  Future<void> _loadFollowerDetails() async {
    try {
      isLoadingFollowers.value = true;
      final List<UserModel> users = [];

      for (var followerId in userController.followerIds) {
        final user = await _userRepo.getUserDetails(followerId);
        if (user.id!.isNotEmpty) {
          users.add(user);
        }
      }

      followerUsers.assignAll(users);
    } catch (e) {
      debugPrint('❌ Lỗi khi tải followers: $e');
    } finally {
      isLoadingFollowers.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          'Người theo dõi (${userController.followerIds.length})',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        )),
        centerTitle: true,
      ),
      body: Obx(() {
        if (isLoadingFollowers.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.buttonColor),
          );
        }

        if (userController.followerIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có người theo dõi',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: followerUsers.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = followerUsers[index];
            return _buildFollowerTile(user);
          },
        );
      }),
    );
  }

  Widget _buildFollowerTile(UserModel user) {
    return Obx(() {
      final isFollowingBack = userController.followingIds.contains(user.id);
      final isFriend = isFollowingBack; // In followers list, if we follow them back, they are friends

      return ListTile(
        onTap: () {
          if (user.id != null && user.id!.isNotEmpty) {
            final currentUid = FirebaseAuth.instance.currentUser?.uid;
            if (user.id == currentUid) {
              NavigationController.instance.changeIndex(4);
              Get.back();
            } else {
              Get.to(() => ProfileHubScreen(userId: user.id));
            }
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(
            user.profilePicture.isNotEmpty
                ? user.profilePicture
                : 'https://picsum.photos/200',
          ),
        ),
        title: Text(
          user.fullName.isNotEmpty ? user.fullName : user.username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '@${user.username}',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        trailing: ElevatedButton(
          onPressed: () => userController.toggleFollowUser(user.id ?? ""),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFriend ? Colors.green : (isFollowingBack ? Colors.grey[300] : AppColors.buttonColor),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            isFriend ? 'Bạn bè' : (isFollowingBack ? 'Đang theo dõi' : 'Theo dõi lại'),
            style: TextStyle(
              fontSize: 12,
              color: isFriend ? Colors.white : (isFollowingBack ? Colors.black : Colors.white),
            ),
          ),
        ),
      );
    });
  }
}

