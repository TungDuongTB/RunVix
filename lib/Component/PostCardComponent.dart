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

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        post.imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
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
          onPressed: () {
            // Mở màn hình bình luận
          },
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
