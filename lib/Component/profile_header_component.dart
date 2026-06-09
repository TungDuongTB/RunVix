import 'package:runvix/export.dart';

class ProfileHeaderComponent extends StatelessWidget {
  final String avatarUrl;
  final String fullName;
  final String subtitle;
  final String bio;
  final int following;
  final int followers;
  final int likes;
  final int streakCount;
  final double totalDistance;
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
    this.streakCount = 0,
    this.totalDistance = 0.0,
    this.isFollowing = false,
    this.isFollower = false,
    this.onFollowPressed,
    this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Avatar with active gradient ring
        const SizedBox(height: 24),
        _buildAvatarSection(),

        const SizedBox(height: 16),
        // 2. Name & Bio
        _buildNameAndBioSection(),

        const SizedBox(height: 24),
        // 3. Stats Row: Followers | Following | Likes
        ProfileStatsRow(
          followers: followers,
          following: following,
          likes: likes,
          onStatTap: onStatTap,
        ),

        const SizedBox(height: 24),
        // 4. Streak & Distance Cards
        ProfileStreakDistanceCards(
          streakCount: streakCount,
          totalDistance: totalDistance,
        ),

        const SizedBox(height: 12),
        // 5. Follow Button
        _buildFollowButton(),
      ],
    );
  }

  /// ===== Header: Avatar with gradient border =====
  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.buttonColor, // Primary Orange
            AppColors.secondaryBlue, // Secondary Blue
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage(avatarUrl),
          onBackgroundImageError: (exception, stackTrace) {},
        ),
      ),
    );
  }

  /// ===== Name & Bio Section =====
  Widget _buildNameAndBioSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkNavy,
              fontFamily: 'Plus Jakarta Sans',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            bio.isNotEmpty ? bio : subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.darkBronze,
              height: 1.4,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
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
        : (isFollowing
              ? 'Đã theo dõi'
              : (isFollower ? 'Theo dõi lại' : 'Theo dõi'));

    // Determine colors based on state
    final Color buttonBgColor = isFriend
        ? Colors.green
        : (isFollowing ? AppColors.lightBlue : AppColors.buttonColor);

    final Color buttonFgColor = isFriend
        ? Colors.white
        : (isFollowing ? AppColors.darkNavy : Colors.white);

    final BorderSide borderSide = isFollowing
        ? const BorderSide(color: AppColors.peach)
        : BorderSide.none;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBgColor,
            foregroundColor: buttonFgColor,
            elevation: 0,
            side: borderSide,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onFollowPressed,
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      ),
    );
  }
}
