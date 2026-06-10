import 'package:runvix/export.dart';
import '../Model/notification_model.dart';
import '../Repository/notification_repository.dart';

class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();

  final _notificationRepo = NotificationRepository.instance;
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;

  // Cache user details to avoid repeated fetches
  final userCache = <String, UserModel>{}.obs;

  StreamSubscription? _notificationSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToNotifications();
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    super.onClose();
  }

  void _listenToNotifications() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _notificationSubscription?.cancel();
      if (user != null) {
        _notificationSubscription = _notificationRepo
            .getNotificationsStream(user.uid)
            .listen(
              (list) {
                notifications.assignAll(list);
                unreadCount.value = list.where((n) => !n.isRead).length;

                // Pre-fetch sender user info for caching
                for (var n in list) {
                  if (n.senderIds.isNotEmpty) {
                    getUserInfo(n.senderIds.first);
                  }
                }
              },
              onError: (error) {
                debugPrint("❌ Error listening to notifications: $error");
              },
            );
      } else {
        notifications.clear();
        unreadCount.value = 0;
      }
    });
  }

  // Fetch or retrieve user info from cache
  Future<UserModel> getUserInfo(String userId) async {
    if (userCache.containsKey(userId)) {
      return userCache[userId]!;
    }

    try {
      final user = await UserRepository.instance.getUserDetails(userId);
      userCache[userId] = user;
      return user;
    } catch (e) {
      debugPrint("Error fetching user details for notification: $e");
      return UserModel.empty().copyWith(
        id: userId,
        fullName: "Người dùng RunVix",
      );
    }
  }

  Future<void> markAsRead(String id) async {
    await _notificationRepo.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _notificationRepo.markAllAsRead(uid);
    }
  }

  Future<void> handleNotificationTap(NotificationModel notification) async {
    if (notification.id != null) {
      await markAsRead(notification.id!);
    }

    final senderId = notification.senderIds.isNotEmpty
        ? notification.senderIds.first
        : null;

    if (notification.type == "follow" ||
        notification.type == "follow_back" ||
        notification.type == "friend") {
      if (senderId != null) {
        Get.to(() => ProfileHubScreen(userId: senderId));
      }
    } else if (notification.type == "like" || notification.type == "comment") {
      final postId = notification.postId;
      if (postId != null) {
        try {
          Get.dialog(
            const Center(
              child: CircularProgressIndicator(color: AppColors.buttonColor),
            ),
            barrierDismissible: false,
          );

          final doc = await FirebaseFirestore.instance
              .collection("Posts")
              .doc(postId)
              .get();
          Get.back(); // Dismiss loading dialog

          if (doc.exists) {
            // Load user data for the post creator
            final postData = doc.data()!;
            final postUserId = postData["UserId"] ?? "";

            String authorName = "Người dùng RunVix";
            String authorAvatar = "";
            if (postUserId.isNotEmpty) {
              final author = await getUserInfo(postUserId);
              authorName = author.fullName;
              authorAvatar = author.profilePicture;
            }

            final post = PostModel.fromSnapshot(
              doc,
              userName: authorName,
              userProfilePicture: authorAvatar,
            );

            if (notification.type == "comment") {
              Get.to(
                () => CommentScreen(
                  post: post,
                  focusCommentId: notification.commentId,
                ),
              );
            } else {
              Get.to(() => CommentScreen(post: post));
            }
          } else {
            Get.snackbar("Thông báo", "Bài viết này đã bị xóa.");
          }
        } catch (e) {
          if (Get.isDialogOpen ?? false) Get.back();
          Get.snackbar("Lỗi", "Không thể tải chi tiết bài viết: $e");
        }
      }
    }
  }
}
