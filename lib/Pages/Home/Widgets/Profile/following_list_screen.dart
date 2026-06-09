import 'package:runvix/export.dart';
import '../../../../Component/UserCardComponent.dart';

class FollowingListScreen extends StatefulWidget {
  final String? userId;

  const FollowingListScreen({super.key, this.userId});

  @override
  State<FollowingListScreen> createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen> {
  late final userController = UserController.instance;
  late final _userRepo = Get.put(UserRepository());
  final followingUsers = <UserModel>[].obs;
  final isLoadingFollowing = false.obs;

  @override
  void initState() {
    super.initState();
    _loadFollowingDetails();
    // Lắng nghe following IDs real-time
    ever(userController.followingIds, (_) {
      _loadFollowingDetails();
    });
  }

  Future<void> _loadFollowingDetails() async {
    try {
      isLoadingFollowing.value = true;
      final List<UserModel> users = [];

      for (var followingId in userController.followingIds) {
        final user = await _userRepo.getUserDetails(followingId);
        if (user.id!.isNotEmpty) {
          users.add(user);
        }
      }

      followingUsers.assignAll(users);
    } catch (e) {
      debugPrint('❌ Lỗi khi tải following list: $e');
    } finally {
      isLoadingFollowing.value = false;
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
          'Đang theo dõi (${userController.followingIds.length})',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        )),
        centerTitle: true,
      ),
      body: Obx(() {
        if (isLoadingFollowing.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.buttonColor),
          );
        }

        if (userController.followingIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Bạn chưa theo dõi ai',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: followingUsers.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = followingUsers[index];
            return _buildFollowingTile(user);
          },
        );
      }),
    );
  }

  Widget _buildFollowingTile(UserModel user) {
    return Obx(() {
      final isFollower = userController.followerIds.contains(user.id);

      return ListTile(
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${user.username}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            if (isFollower)
              const Text(
                'Theo dõi bạn',
                style: TextStyle(color: AppColors.buttonColor, fontSize: 11, fontWeight: FontWeight.w500),
              ),
          ],
        ),
        trailing: TextButton(
          onPressed: () => userController.toggleFollowUser(user.id ?? ""),
          child: const Text(
            'Bỏ theo dõi',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      );
    });
  }
}

