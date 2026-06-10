import 'package:runvix/export.dart';

class GroupDetailRequirementsSection extends StatelessWidget {
  final GroupModel group;

  const GroupDetailRequirementsSection({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    if (!group.hasRequirements) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yêu cầu tham gia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              fontFamily: 'Hanken Grotesk',
            ),
          ),
          const SizedBox(height: 12),
          if (group.minPace.isNotEmpty)
            _RequirementRow(icon: Icons.speed, text: 'Pace tối thiểu: ${group.minPace}'),
          if (group.minKm.isNotEmpty)
            _RequirementRow(icon: Icons.route, text: 'Km tối thiểu: ${group.minKm}'),
          if (group.minSessions.isNotEmpty)
            _RequirementRow(icon: Icons.event, text: 'Buổi tập/tháng: ${group.minSessions}'),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RequirementRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.buttonColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
