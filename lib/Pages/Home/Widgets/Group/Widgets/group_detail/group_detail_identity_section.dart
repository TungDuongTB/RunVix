import 'package:runvix/export.dart';

class GroupDetailIdentitySection extends StatelessWidget {
  final GroupModel group;
  final String creatorName;
  final bool loadingCreator;

  const GroupDetailIdentitySection({
    super.key,
    required this.group,
    required this.creatorName,
    required this.loadingCreator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            fontFamily: 'Hanken Grotesk',
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.person_outline, size: 16, color: AppColors.outline),
            const SizedBox(width: 6),
            Text.rich(
              TextSpan(
                text: 'Quản trị viên: ',
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                  fontFamily: 'Hanken Grotesk',
                ),
                children: [
                  TextSpan(
                    text: loadingCreator ? '...' : creatorName,
                    style: const TextStyle(
                      color: AppColors.buttonColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _GroupDetailChip(
              icon: group.isPublic ? Icons.public : Icons.lock_outline,
              label: group.isPublic ? 'Công khai' : 'Riêng tư',
              color: AppColors.secondary,
              bgColor: AppColors.secondaryContainer.withOpacity(0.1),
            ),
            _GroupDetailChip(
              icon: Icons.directions_run,
              label: 'Chạy bộ',
              color: AppColors.buttonColor,
              bgColor: AppColors.buttonColor.withOpacity(0.1),
            ),
            if (group.location.isNotEmpty)
              _GroupDetailChip(
                icon: Icons.location_on_outlined,
                label: group.location,
                color: AppColors.onSurfaceVariant,
                bgColor: AppColors.surfaceContainer,
              ),
          ],
        ),
      ],
    );
  }
}

class _GroupDetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _GroupDetailChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Hanken Grotesk',
            ),
          ),
        ],
      ),
    );
  }
}
