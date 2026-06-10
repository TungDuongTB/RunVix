import 'package:runvix/export.dart';

class GroupDetailPostsSection extends StatelessWidget {
  const GroupDetailPostsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bài viết từ trưởng nhóm',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            fontFamily: 'Hanken Grotesk',
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            children: const [
              Icon(Icons.article_outlined, size: 40, color: AppColors.outline),
              SizedBox(height: 8),
              Text(
                'Chưa có bài viết từ trưởng nhóm',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
