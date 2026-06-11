import 'package:runvix/export.dart';
import 'group_detail_stats_utils.dart';

class GroupDetailStatsSection extends StatelessWidget {
  final GroupModel group;
  final int eventCount;
  final bool loadingStats;
  final GroupWorkoutStats stats;

  const GroupDetailStatsSection({
    super.key,
    required this.group,
    required this.eventCount,
    required this.loadingStats,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final memberCount = group.memberIds.length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.15,
      children: [
        GroupDetailStatCard(
          label: 'Thành viên',
          value: '$memberCount',
          subtitle: GroupDetailStats.memberSubtitle(memberCount),
          valueColor: AppColors.secondaryContainer,
        ),
        GroupDetailStatCard(
          label: 'Tổng quãng đường',
          value: loadingStats ? '...' : stats.formattedTotalDistance,
          subtitle: 'Kilometers',
          valueColor: AppColors.buttonColor,
        ),
        GroupDetailStatCard(
          label: 'Tốc độ TB',
          value: loadingStats ? '...' : stats.formattedAveragePace,
          subtitle: 'min/km',
          valueColor: AppColors.secondaryContainer,
        ),
        GroupDetailStatCard(
          label: 'Số sự kiện',
          value: '$eventCount',
          subtitle: 'Sự kiện',
          valueColor: AppColors.buttonColor,
        ),
      ],
    );
  }
}

class GroupDetailStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color valueColor;

  const GroupDetailStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
              letterSpacing: 0.5,
              height: 1.2,
              fontFamily: 'Hanken Grotesk',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: valueColor,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.outline,
              fontSize: 11,
              fontFamily: 'Hanken Grotesk',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
