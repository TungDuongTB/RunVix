import 'package:runvix/export.dart';
import '../../../../Component/PostCardComponent.dart';

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

            final visiblePosts = postController.allPosts.where((p) => !p.isLocked).toList();

            if (visiblePosts.isEmpty) {
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
              itemCount: visiblePosts.length + (postController.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < visiblePosts.length) {
                  return PostCard(post: visiblePosts[index]);
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
