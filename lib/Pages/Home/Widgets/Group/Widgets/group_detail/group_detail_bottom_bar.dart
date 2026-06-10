import 'package:runvix/export.dart';
import 'group_detail_dialogs.dart';

class GroupDetailBottomBar extends StatelessWidget {
  final GroupModel group;
  final bool isCreator;
  final bool isMember;

  const GroupDetailBottomBar({
    super.key,
    required this.group,
    required this.isCreator,
    required this.isMember,
  });

  @override
  Widget build(BuildContext context) {
    if (isCreator) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Bạn là người tạo nhóm ${group.name}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.outline,
                fontSize: 12,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
          ),
          const SizedBox(height: 16),
          _DeleteGroupButton(onPressed: () => GroupDetailDialogs.confirmDeleteGroup(group)),
        ],
      );
    }

    if (isMember) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Bạn đang là thành viên của nhóm ${group.name}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.outline,
                fontSize: 12,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LeaveGroupButton(onPressed: () => GroupDetailDialogs.confirmLeaveGroup(group)),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class GroupDetailJoinButton extends StatelessWidget {
  final GroupModel group;
  final bool compact;
  final VoidCallback? onJoin;

  const GroupDetailJoinButton({
    super.key,
    required this.group,
    this.compact = false,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.buttonColor, AppColors.buttonColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonColor.withOpacity(0.3),
            blurRadius: compact ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(compact ? 10 : 12),
          onTap: onJoin ?? () => GroupController.instance.joinGroup(group),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 32,
              vertical: compact ? 8 : 14,
            ),
            child: Text(
              compact ? 'Tham gia' : 'Tham gia nhóm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: compact ? 13 : 15,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteGroupButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DeleteGroupButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.delete_forever_outlined, size: 18),
      label: const Text('Xóa nhóm'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: const BorderSide(color: AppColors.danger),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _LeaveGroupButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LeaveGroupButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.exit_to_app, size: 18),
      label: const Text('Rời nhóm'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: BorderSide(color: AppColors.danger.withOpacity(0.6)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
