
import 'package:runvix/export.dart';

class UserFollowCard extends StatelessWidget {
  final UserModel user;
  final bool isFollowing;
  final bool isFollower;
  final VoidCallback? onFollow;
  final VoidCallback? onRemove;

  const UserFollowCard({
    super.key,
    required this.user,
    this.isFollowing = false,
    this.isFollower = false,
    this.onFollow,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildAvatar(),
          const SizedBox(height: 16),
          _buildUserInfo(),
          const Spacer(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () {
        if (user.id != null && user.id!.isNotEmpty) {
          Get.to(() => ProfileHubScreen(userId: user.id));
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              user.profilePicture.isNotEmpty ? user.profilePicture : 'https://picsum.photos/100',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.account_circle, size: 70, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return GestureDetector(
      onTap: () {
        if (user.id != null && user.id!.isNotEmpty) {
          Get.to(() => ProfileHubScreen(userId: user.id));
        }
      },
      child: Column(
        children: [
          Text(
            user.fullName.isNotEmpty ? user.fullName : 'Người dùng RunVix',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            user.username.isNotEmpty ? "@${user.username}" : user.email,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final userController = UserController.instance;

    return Obx(() {
      // Directly access observables trong Obx để nó lắng nghe changes
      final isFollowingNow = userController.followingIds.contains(user.id);
      final isFollowerNow = userController.followerIds.contains(user.id);
      final isFriend = isFollowingNow && isFollowerNow; // Both follow each other

      // Determine button state and color
      final buttonBgColor = isFriend ? Colors.green : (isFollowingNow ? Colors.grey.shade200 : AppColors.buttonColor);
      final buttonFgColor = isFriend ? Colors.white : (isFollowingNow ? Colors.black87 : Colors.white);
      final buttonBorderColor = isFriend ? Colors.green : (isFollowingNow ? Colors.grey.shade300 : null);

      return Column(
        children: [
          ElevatedButton(
            onPressed: onFollow,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBgColor,
              foregroundColor: buttonFgColor,
              elevation: 0,
              side: buttonBorderColor != null ? BorderSide(color: buttonBorderColor) : null,
              minimumSize: const Size(double.infinity, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              isFriend ? 'Bạn bè' : (isFollowingNow ? 'Đã theo dõi' : (isFollowerNow ? 'Theo dõi lại' : 'Theo dõi')),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          OutlinedButton(
            onPressed: onRemove,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              minimumSize: const Size(double.infinity, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ),
        ],
      );
    });
  }
}
