import 'package:runvix/export.dart';
import 'package:intl/intl.dart' as intl;
import 'package:runvix/Data/Controller/comment_controller.dart';

class CommentScreen extends StatefulWidget {
  final PostModel post;
  final String? focusCommentId;
  
  const CommentScreen({super.key, required this.post, this.focusCommentId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final Map<String, GlobalKey> commentKeys = {};
  late CommentController controller;
  final userController = UserController.instance;
  final ScrollController _scrollController = ScrollController();
  Worker? _scrollWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CommentController(postId: widget.post.id!));

    // Listen to changes in isLoading to scroll to focused comment
    _scrollWorker = ever(controller.isLoading, (bool loading) {
      if (!loading && widget.focusCommentId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToFocusedComment();
        });
      }
    });

    // Initial check if comments are already loaded
    if (!controller.isLoading.value && widget.focusCommentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFocusedComment();
      });
    }
  }

  @override
  void dispose() {
    _scrollWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFocusedComment() {
    final key = commentKeys[widget.focusCommentId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Post Details", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Post Card in Header
                  _buildPostCard(),
                  const SizedBox(height: 24),
                  const Text(
                    "Comments",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  // Comments List
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (controller.comments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                "Chưa có bình luận nào.\nBạn hãy trở thành người đầu tiên!",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.comments.length,
                      itemBuilder: (context, index) {
                        final comment = controller.comments[index];
                        final key = commentKeys.putIfAbsent(comment.id ?? index.toString(), () => GlobalKey());
                        return Container(
                          key: key,
                          child: _buildCommentItem(comment),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Input Area
          _buildInputArea(controller, userController),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    final isLike = widget.post.isLiked;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightPurple, // Nhạt tím/hồng theo ảnh
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (widget.post.userId.isNotEmpty) {
                    final currentUid = FirebaseAuth.instance.currentUser?.uid;
                    if (widget.post.userId == currentUid) {
                      NavigationController.instance.changeIndex(4);
                      Get.back();
                    } else {
                      Get.to(() => ProfileHubScreen(userId: widget.post.userId));
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: widget.post.userProfilePicture.isNotEmpty
                      ? NetworkImage(widget.post.userProfilePicture)
                      : const AssetImage('assets/Images/default_avatar.png') as ImageProvider,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.post.userId.isNotEmpty) {
                        final currentUid = FirebaseAuth.instance.currentUser?.uid;
                        if (widget.post.userId == currentUid) {
                          NavigationController.instance.changeIndex(4);
                          Get.back();
                        } else {
                          Get.to(() => ProfileHubScreen(userId: widget.post.userId));
                        }
                      }
                    },
                    child: Text(
                      widget.post.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Text(
                    widget.post.createdAt != null 
                        ? "${intl.DateFormat('dd/MM/yyyy HH:mm').format(widget.post.createdAt!)}"
                        : "Just now",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.post.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.post.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          Text(
            widget.post.content,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),
          if (widget.post.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.post.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                  isLike ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isLike ? Colors.red : Colors.grey
              ),
              const SizedBox(width: 4),
              Text("${widget.post.likes}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text("${widget.post.comments}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    final isFocused = widget.focusCommentId != null && comment.id == widget.focusCommentId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (comment.userId.isNotEmpty) {
                final currentUid = FirebaseAuth.instance.currentUser?.uid;
                if (comment.userId == currentUid) {
                  NavigationController.instance.changeIndex(4);
                  Get.back();
                } else {
                  Get.to(() => ProfileHubScreen(userId: comment.userId));
                }
              }
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: comment.userProfilePicture.isNotEmpty
                  ? NetworkImage(comment.userProfilePicture)
                  : const AssetImage('assets/Images/default_avatar.png') as ImageProvider,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (comment.userId.isNotEmpty) {
                          final currentUid = FirebaseAuth.instance.currentUser?.uid;
                          if (comment.userId == currentUid) {
                            NavigationController.instance.changeIndex(4);
                            Get.back();
                          } else {
                            Get.to(() => ProfileHubScreen(userId: comment.userId));
                          }
                        }
                      },
                      child: Text(
                        comment.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Text(
                      comment.createdAt != null
                          ? "${intl.DateFormat('dd/MM/yyyy HH:mm').format(comment.createdAt!)}"
                          : "",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple, // Màu tím nhạt cho bubble
                    borderRadius: BorderRadius.circular(12),
                    border: isFocused ? Border.all(color: AppColors.buttonColor, width: 1.5) : null,
                  ),
                  child: Text(
                    comment.comment,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(CommentController controller, UserController userController) {
    return Container(
      padding: EdgeInsets.only(
        left: 16, 
        right: 16, 
        top: 12, 
        bottom: Get.context != null ? MediaQuery.of(Get.context!).viewInsets.bottom + 12 : 12
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Obx(() => CircleAvatar(
              radius: 18,
              backgroundImage: userController.user.value.profilePicture.isNotEmpty == true
                  ? NetworkImage(userController.user.value.profilePicture)
                  : const AssetImage('assets/Images/default_avatar.png') as ImageProvider,
            )),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.commentContent,
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => controller.sendComment(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primary, // Màu tím đậm cho nút gửi
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
