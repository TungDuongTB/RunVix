import 'package:runvix/export.dart';

class ProfileHeaderComponent extends StatelessWidget {
  final String avatarUrl;
  final String fullName;
  final String subtitle;
  final String bio;
  final int following;
  final int followers;
  final int likes;
  final bool isFollowing;
  final bool isFollower;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onStatTap;

  const ProfileHeaderComponent({
    super.key,
    required this.avatarUrl,
    required this.fullName,
    this.subtitle = 'Runner • Fitness',
    this.bio = '🏃‍♂️ Follow me for updates',
    required this.following,
    required this.followers,
    required this.likes,
    this.isFollowing = false,
    this.isFollower = false,
    this.onFollowPressed,
    this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header: Avatar + Name (Horizontal)
        _buildHeaderSection(),

        const SizedBox(height: 16),

        // Stats Row: Following | Followers | Likes
        _buildStatsRow(),

        const SizedBox(height: 20),

        // Bio Section
        _buildBioSection(),

        const SizedBox(height: 16),

        // Follow Button
        _buildFollowButton(),
      ],
    );
  }

  /// ===== Header: Avatar + Name (Horizontal) =====
  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(avatarUrl),
            onBackgroundImageError: (exception, stackTrace) {},
          ),
          const SizedBox(width: 16),
          // Name & Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ===== Stats Row: Following | Followers | Likes =====
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Đang theo dõi', following.toString()),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem('Người theo dõi', followers.toString()),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem('Lượt thích', likes.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return GestureDetector(
      onTap: onStatTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// ===== Bio Section =====
  Widget _buildBioSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bio,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// ===== Follow Button =====
  Widget _buildFollowButton() {
    if (onFollowPressed == null) return const SizedBox.shrink();

    final bool isFriend = isFollowing && isFollower;

    // Determine button text
    final String buttonText = isFriend
        ? 'Bạn bè'
        : (isFollowing ? 'Đã theo dõi' : (isFollower ? 'Theo dõi lại' : 'Theo dõi'));

    // Determine colors based on state
    final Color buttonBgColor = isFriend
        ? Colors.green
        : (isFollowing ? Colors.grey.shade200 : AppColors.buttonColor);

    final Color buttonFgColor = isFriend
        ? Colors.white
        : (isFollowing ? Colors.black87 : Colors.white);

    final BorderSide borderSide = isFriend
        ? const BorderSide(color: Colors.green)
        : (isFollowing ? BorderSide(color: Colors.grey.shade300) : BorderSide.none);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBgColor,
            foregroundColor: buttonFgColor,
            side: borderSide,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onFollowPressed,
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
