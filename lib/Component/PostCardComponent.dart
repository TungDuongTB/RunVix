import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:runvix/export.dart';
import 'package:intl/intl.dart' as intl;

class PostCard extends StatelessWidget {
  final PostModel post;
  
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final postController = PostController.instance;
    final userController = UserController.instance;

    final hasImage = post.imageUrl.isNotEmpty;
    final hasStats = post.distance != null && post.distance! > 0;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildBody(),
          const SizedBox(height: 12),
          if (hasStats && !hasImage) ...[
            _buildStats(),
            const SizedBox(height: 12),
          ],
          if (hasImage) ...[
            _buildImageAndStats(hasStats),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          Divider(height: 1, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 8),
          _buildActions(postController, userController),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: post.userProfilePicture.isNotEmpty 
                ? NetworkImage(post.userProfilePicture) 
                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
            child: post.userProfilePicture.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName.isNotEmpty ? post.userName : "Người dùng RunVix",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              ),
              if (post.createdAt != null)
                Text(
                  intl.DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt!),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
          ),
        Text(
          post.content,
          style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Quãng đường", "${post.distance?.toStringAsFixed(2)} km", Icons.straighten),
          _buildStatItem("Thời gian", _formatDuration(post.duration ?? 0), Icons.timer_outlined),
          _buildStatItem("Nhịp độ", "${post.averagePace?.toStringAsFixed(2)} /km", Icons.speed),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label, 
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w900, 
            fontStyle: FontStyle.italic,
            color: AppColors.buttonColor
          )
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return "${hours}g ${minutes}p";
    }
    return "${minutes}p ${secs}s";
  }

  Widget _buildImageAndStats(bool hasStats) {
    if (post.imageUrl.isEmpty || !post.imageUrl.startsWith('http')) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            Image.network(
              post.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade100,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, color: Colors.grey, size: 40),
                    SizedBox(height: 8),
                    Text("Không thể hiển thị bản đồ quãng đường", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
            ),
            if (hasStats)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOverlayStatItem("Quãng đường", "${post.distance?.toStringAsFixed(2)} km"),
                          _buildOverlayStatItem("Thời gian", _formatDuration(post.duration ?? 0)),
                          _buildOverlayStatItem("Nhịp độ", "${post.averagePace?.toStringAsFixed(2)} /km"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(), 
          style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 2),
        Text(
          value, 
          style: const TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.w900, 
            fontStyle: FontStyle.italic,
            color: Color(0xFFEFF6FF)
          )
        ),
      ],
    );
  }

  Widget _buildActions(PostController postController, UserController userController) {
    final isLiked = post.isLiked;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton.icon(
          onPressed: () => postController.toggleLike(post),
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border, 
            size: 20, 
            color: isLiked ? Colors.red : Colors.grey.shade600
          ),
          label: Text(
            "${post.likes} Thích",
            style: TextStyle(color: isLiked ? Colors.red : Colors.grey.shade600, fontSize: 13),
          ),
        ),
        TextButton.icon(
          onPressed: () => Get.to(() => CommentScreen(post: post)),
          icon: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey.shade600),
          label: Text(
            "${post.comments} Bình luận",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
