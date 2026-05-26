import 'package:flutter/material.dart';
import 'package:runvix/export.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          Padding(
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
          ),
          const Divider(indent: 16, endIndent: 16),
          Padding(
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
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: Obx(() {
              if (userController.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
              }

              // Lọc bỏ user hiện tại và những người có vai trò admin/điều phối khỏi danh sách gợi ý
              final displayUsers = userController.allUsers
                  .where((u) => u.id != currentUserId && u.role != 'admin' && u.role != 'coordinator')
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
                  final userItem = displayUsers[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildFollowCard(userItem),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowCard(UserModel user) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  user.profilePicture.isNotEmpty ? user.profilePicture : 'https://picsum.photos/100',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.account_circle, size: 70, color: Colors.grey),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: AppColors.buttonColor, shape: BoxShape.circle),
                  child: const Icon(Icons.add, size: 12, color: Colors.white),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName.isNotEmpty ? user.fullName : 'Người dùng RunVix',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            user.username.isNotEmpty ? "@${user.username}" : user.email,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Theo dõi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          const SizedBox(height: 4),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              minimumSize: const Size(double.infinity, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
