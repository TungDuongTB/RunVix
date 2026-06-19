import 'package:runvix/export.dart';

class ProfileStatsRow extends StatelessWidget {
  final int followers;
  final int following;
  final int likes;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onLikesTap;

  const ProfileStatsRow({
    super.key,
    required this.followers,
    required this.following,
    required this.likes,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onLikesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('Followers', _formatCount(followers), onFollowersTap)),
          Container(
            width: 1,
            height: 32,
            color: const Color(0xFFE4BFB1).withOpacity(0.3),
          ),
          Expanded(child: _buildStatItem('Following', _formatCount(following), onFollowingTap)),
          Container(
            width: 1,
            height: 32,
            color: const Color(0xFFE4BFB1).withOpacity(0.3),
          ),
          Expanded(child: _buildStatItem('Likes', _formatCount(likes), onLikesTap)),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  Widget _buildStatItem(String label, String value, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.buttonColor,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBronze,
              letterSpacing: 1.2,
              fontFamily: 'Geist',
            ),
          ),
        ],
      ),
    );
  }
}
