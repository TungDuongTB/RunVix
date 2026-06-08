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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildBody(),
          const SizedBox(height: 12),
          if (post.distance != null && post.distance! > 0) ...[
            _buildStats(),
            const SizedBox(height: 12),
          ],
          if (post.imageUrl.isNotEmpty) _buildImage(),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _buildActions(postController, userController),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: post.userProfilePicture.isNotEmpty 
              ? NetworkImage(post.userProfilePicture) 
              : const AssetImage('assets/Images/default_avatar.png') as ImageProvider,
          child: post.userProfilePicture.isEmpty
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName.isNotEmpty ? post.userName : "Người dùng RunVix",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (post.createdAt != null)
                Text(
                  intl.DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt!),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
        Text(
          post.content,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.buttonColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.buttonColor.withOpacity(0.1)),
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
            Icon(icon, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.buttonColor)),
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

  Widget _buildImage() {
    if (post.imageUrl.isEmpty || !post.imageUrl.startsWith('http')) {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9, // Tỷ lệ chuẩn cho bản đồ
            child: Image.network(
              post.imageUrl,
              width: double.infinity,
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
          ),
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
            color: isLiked ? Colors.red : Colors.grey
          ),
          label: Text(
            "${post.likes} Thích",
            style: TextStyle(color: isLiked ? Colors.red : Colors.grey),
          ),
        ),
        TextButton.icon(
          onPressed: () => Get.to(() => CommentScreen(post: post)),
          icon: const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
          label: Text(
            "${post.comments} Bình luận",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
