import 'package:runvix/export.dart';

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
}
