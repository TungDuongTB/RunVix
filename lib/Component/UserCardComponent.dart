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
    return GlassCard(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Container(
        width: 150,
        height: 220,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Close/Dismiss Button in Top-Right
            if (onRemove != null)
              Positioned(
                top: -8,
                right: -8,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onRemove,
                ),
              ),
            
            // Card Content
            Column(
              children: [
                const SizedBox(height: 8),
                _buildAvatar(),
                const SizedBox(height: 12),
                _buildUserInfo(),
                const Spacer(),
                _buildActionButtons(),
              ],
            ),
          ],
        ),
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
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.network(
            user.profilePicture.isNotEmpty ? user.profilePicture : 'https://picsum.photos/100',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.account_circle, size: 60, color: Colors.grey),
          ),
        ),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            user.username.isNotEmpty ? "@${user.username}" : user.email,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
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
      final isFollowingNow = userController.followingIds.contains(user.id);
      final isFollowerNow = userController.followerIds.contains(user.id);
      final isFriend = isFollowingNow && isFollowerNow;

      final buttonBgColor = isFriend 
          ? Colors.green.shade600 
          : (isFollowingNow ? Colors.white.withOpacity(0.3) : AppColors.buttonColor);
      final buttonFgColor = isFriend 
          ? Colors.white 
          : (isFollowingNow ? Colors.grey.shade800 : Colors.white);
      final buttonBorderColor = isFriend 
          ? Colors.transparent 
          : (isFollowingNow ? Colors.white.withOpacity(0.4) : Colors.transparent);

      return SizedBox(
        width: double.infinity,
        height: 32,
        child: ElevatedButton(
          onPressed: onFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBgColor,
            foregroundColor: buttonFgColor,
            elevation: 0,
            side: BorderSide(color: buttonBorderColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: Text(
            isFriend ? 'Bạn bè' : (isFollowingNow ? 'Đã theo dõi' : (isFollowerNow ? 'Theo dõi lại' : 'Theo dõi')),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      );
    });
  }
}
