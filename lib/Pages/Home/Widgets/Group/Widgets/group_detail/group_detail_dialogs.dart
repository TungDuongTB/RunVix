import 'package:runvix/export.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupDetailDialogs {
  GroupDetailDialogs._();

  static void confirmDeleteGroup(GroupModel group) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xóa nhóm'),
        content: Text(
          'Bạn có chắc muốn xóa nhóm "${group.name}"? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              GroupController.instance.deleteGroup(group);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Xóa nhóm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void confirmLeaveGroup(GroupModel group) {
    Get.dialog(
      AlertDialog(
        title: const Text('Rời nhóm'),
        content: Text('Bạn có chắc muốn rời khỏi nhóm "${group.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              GroupController.instance.leaveGroup(group);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Rời nhóm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Future<dynamic> showEventDetail(BuildContext context, ChallengeModel challenge) {
    return Get.dialog(
      Obx(() {
        final currentChallenge = ChallengeController.instance.challenges.firstWhere(
          (c) => c.id == challenge.id,
          orElse: () => challenge,
        );
        final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
        final isJoined = currentChallenge.joinedUserIds.contains(uid);
        final isCreator = currentChallenge.creatorId == uid;
        final start = '${currentChallenge.startDate.day}/${currentChallenge.startDate.month}/${currentChallenge.startDate.year} ${currentChallenge.startDate.hour.toString().padLeft(2, '0')}:${currentChallenge.startDate.minute.toString().padLeft(2, '0')}';

        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            currentChallenge.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Hanken Grotesk',
              fontSize: 20,
              color: AppColors.buttonColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentChallenge.imageUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      currentChallenge.imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        start,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontFamily: 'Hanken Grotesk',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${currentChallenge.joinedUserIds.length} người đã tham gia',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Hanken Grotesk',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mô tả sự kiện',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Hanken Grotesk',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currentChallenge.description.isNotEmpty
                      ? currentChallenge.description
                      : 'Không có mô tả chi tiết cho sự kiện này.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.4,
                    fontFamily: 'Hanken Grotesk',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Đóng',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
            ),
            if (!isCreator && uid.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  ChallengeController.instance.toggleJoinChallenge(currentChallenge);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isJoined ? Colors.grey.shade300 : AppColors.buttonColor,
                  foregroundColor: isJoined ? Colors.black87 : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  isJoined ? 'Đã tham gia' : 'Tham gia',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Hanken Grotesk',
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
