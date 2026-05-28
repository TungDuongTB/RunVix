import 'package:runvix/export.dart';
import 'package:intl/intl.dart' as intl;

class HomeSuggestedChallenges extends StatelessWidget {
  const HomeSuggestedChallenges({super.key});

  @override
  Widget build(BuildContext context) {
    final postController = PostController.instance;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bảng tin cộng đồng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(height: 8),
          const Text(
            'Khám phá các hoạt động từ mọi người',
            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (postController.isLoading.value && postController.allPosts.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ));
            }

            if (postController.allPosts.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Text(
                  'Chưa có bài viết nào.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: postController.allPosts.length + (postController.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < postController.allPosts.length) {
                  return PostCard(post: postController.allPosts[index]);
                } else {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }
}

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
          // Header: Avatar + Tên
          Row(
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
          ),
          const SizedBox(height: 12),

          // Title & Content
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
          const SizedBox(height: 12),

          // Image
          if (post.imageUrl.isNotEmpty)
            ClipRRect(
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
            ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Like Button
              TextButton.icon(
                onPressed: () {
                  if (post.id != null && userController.user.value.id != null) {
                    postController.postRepo.likePost(post.id!, userController.user.value.id!);
                  }
                },
                icon: const Icon(Icons.favorite_border, size: 20, color: Colors.grey),
                label: Text(
                  "${post.likes} Thích",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              // Comment Button
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
          ),
        ],
      ),
    );
  }
}

