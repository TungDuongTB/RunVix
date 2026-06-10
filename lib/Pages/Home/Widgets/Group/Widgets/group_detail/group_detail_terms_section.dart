import 'package:runvix/export.dart';

class GroupDetailTermsSection extends StatefulWidget {
  final String description;

  const GroupDetailTermsSection({super.key, required this.description});

  @override
  State<GroupDetailTermsSection> createState() => _GroupDetailTermsSectionState();
}

class _GroupDetailTermsSectionState extends State<GroupDetailTermsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.gavel, color: AppColors.buttonColor, size: 22),
              SizedBox(width: 8),
              Text(
                'Điều khoản nhóm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? null : TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              height: 1.5,
              fontFamily: 'Hanken Grotesk',
            ),
          ),
          if (widget.description.length > 120)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Thu gọn' : 'Xem thêm',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Hanken Grotesk',
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
