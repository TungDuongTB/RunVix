import 'package:runvix/export.dart';
import '../../../../Component/UserCardComponent.dart';

class HomeSuggestedFollows extends StatelessWidget {
  const HomeSuggestedFollows({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    final calendarController = Get.put(CalendarController());
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickCalendar(calendarController),
          const Divider(indent: 16, endIndent: 16),
          _buildHeader(userController),
          const SizedBox(height: 8),
          _buildUserList(userController, currentUserId),
        ],
      ),
    );
  }

  Widget _buildQuickCalendar(CalendarController calendarController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tạo lịch nhanh (Google Calendar)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.buttonColor),
          ),
          const SizedBox(height: 8),
          Obx(() => TextField(
            onChanged: (value) => calendarController.onSearchChanged(value),
            decoration: InputDecoration(
              hintText: 'Ví dụ: "Chạy bộ lúc 5h chiều mai"',
              prefixIcon: calendarController.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.buttonColor),
                      ),
                    )
                  : const Icon(Icons.auto_awesome, color: AppColors.buttonColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHeader(UserController userController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Nên theo dõi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          TextButton(
            onPressed: () => userController.fetchAllUsers(),
            child: const Text('Xem tất cả', style: TextStyle(color: AppColors.buttonColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(UserController userController, String? currentUserId) {
    return SizedBox(
      height: 280,
      child: Obx(() {
        if (userController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
        }
        final displayUsers = userController.allUsers
            .where((u) => u.id != currentUserId && !u.isAdmin)
            .toList();

        if (displayUsers.isEmpty) {
          return const Center(
            child: Text("Không có người dùng gợi ý", style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: displayUsers.length,
          itemBuilder: (context, index) {
            final otherUser = displayUsers[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: UserFollowCard(
                user: otherUser,
                isFollowing: userController.followingIds.contains(otherUser.id),
                isFollower: userController.followerIds.contains(otherUser.id),
                onFollow: () => userController.toggleFollowUser(otherUser.id ?? ""),
                onRemove: () => Get.to(() => const LoadingScreen()),
              ),
            );
          },
        );
      }),
    );
  }
}