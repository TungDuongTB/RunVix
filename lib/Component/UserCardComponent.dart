import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class UserFollowCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onFollow;
  final VoidCallback? onRemove;

  const UserFollowCard({
    super.key,
    required this.user,
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
    return Stack(
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
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: AppColors.buttonColor, shape: BoxShape.circle),
            child: const Icon(Icons.add, size: 12, color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
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
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Theo dõi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
  }
}
