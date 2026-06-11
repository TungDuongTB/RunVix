import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class InviteFriendsScreen extends StatefulWidget {
  final GroupModel group;

  const InviteFriendsScreen({super.key, required this.group});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final _userRepo = Get.put(UserRepository());
  final userController = UserController.instance;
  final groupController = GroupController.instance;

  final followingUsers = <UserModel>[].obs;
  final isLoading = false.obs;
  final invitedIds = <String>{}.obs;

  @override
  void initState() {
    super.initState();
    _loadFriendsDetails();
  }

  Future<void> _loadFriendsDetails() async {
    try {
      isLoading.value = true;
      final List<UserModel> users = [];
      for (var friendId in userController.followingIds) {
        if (friendId == null || friendId.toString().trim().isEmpty) continue;
        final user = await _userRepo.getUserDetails(friendId);
        if (user != null) {
          users.add(user);
        }
      }
      followingUsers.assignAll(users);

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && widget.group.id != null) {
        final notificationRepo = Get.put(NotificationRepository());
        final pending = await notificationRepo.getPendingInvites(
          currentUser.uid,
          widget.group.id!,
        );
        invitedIds.addAll(pending);
      }
    } catch (e) {
      debugPrint('Lỗi tải danh sách bạn bè: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text(
          'Thêm bạn bè vào nhóm',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'Hanken Grotesk',
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.buttonColor),
          );
        }

        if (followingUsers.isEmpty) {
          return const Center(
            child: Text(
              'Bạn chưa theo dõi ai.',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        // Tìm group mới nhất từ groupController
        final currentGroup = groupController.groups.firstWhere(
          (g) => g.id == widget.group.id,
          orElse: () => widget.group,
        );

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: followingUsers.length,
          itemBuilder: (context, index) {
            final user = followingUsers[index];
            final isMember = currentGroup.memberIds.contains(user.id);
            final isInvited = invitedIds.contains(user.id);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: user.profilePicture.isNotEmpty
                      ? NetworkImage(user.profilePicture)
                      : null,
                  child: user.profilePicture.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                title: Text(
                  user.fullName.isNotEmpty ? user.fullName : user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  '@${user.username}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                trailing: Obx(() {
                  final isInvited = invitedIds.contains(user.id);
                  return isMember
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Đã tham gia',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : isInvited
                    ? OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: BorderSide(color: Colors.blue.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 0,
                          ),
                        ),
                        onPressed: () async {
                          invitedIds.remove(user.id);
                          final success = await groupController
                              .revokeGroupInvite(
                                currentGroup,
                                user.id.toString(),
                              );
                          if (!success) {
                            invitedIds.add(user.id.toString());
                          }
                        },
                        child: const Text(
                          'Đã mời',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 0,
                          ),
                        ),
                        onPressed: () async {
                          invitedIds.add(user.id.toString());
                          final success = await groupController.sendGroupInvite(
                            currentGroup,
                            user.id.toString(),
                          );
                          if (!success) {
                            invitedIds.remove(user.id.toString());
                          }
                        },
                        child: const Text(
                          'Mời',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      );
                }),
              ),
            );
          },
        );
      }),
    );
  }
}
