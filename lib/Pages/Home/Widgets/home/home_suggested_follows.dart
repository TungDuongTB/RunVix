import 'package:runvix/export.dart';
import '../../../../Component/UserCardComponent.dart';

class HomeSuggestedFollows extends StatefulWidget {
  const HomeSuggestedFollows({super.key});

  @override
  State<HomeSuggestedFollows> createState() => _HomeSuggestedFollowsState();
}

class _HomeSuggestedFollowsState extends State<HomeSuggestedFollows> {
  final Set<String> _dismissedIds = {};

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    final calendarController = Get.put(CalendarController());
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickCalendar(calendarController),
          const SizedBox(height: 16),
          Obx(() {
            if (userController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.buttonColor),
              );
            }

            final displayUsers = userController.allUsers.where((u) {
              if (u.id == currentUserId ||
                  u.isAdmin ||
                  _dismissedIds.contains(u.id)) {
                return false;
              }
              final isFollowing = userController.followingIds.contains(u.id);
              return !isFollowing;
            }).toList();

            if (displayUsers.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildUserListWidget(userController, displayUsers),
              ],
            );
          }),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Obx(
              () => TextField(
                onChanged: (value) => calendarController.onSearchChanged(value),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ví dụ: "Chạy bộ lúc 5h chiều mai"',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: calendarController.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.buttonColor,
                            ),
                          ),
                        )
                      : ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColors.buttonColor, AppColors.secondaryBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                          ),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Nên theo dõi',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildUserListWidget(UserController userController, List<UserModel> displayUsers) {
    return SizedBox(
      height: 236,
      child: ListView.builder(
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
              onFollow: () =>
                  userController.toggleFollowUser(otherUser.id ?? ""),
              onRemove: () {
                if (otherUser.id != null) {
                  setState(() {
                    _dismissedIds.add(otherUser.id!);
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}
