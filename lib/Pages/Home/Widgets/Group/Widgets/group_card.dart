import 'package:runvix/export.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final memberCount = group.memberIds.length;

    final currentUser = FirebaseAuth.instance.currentUser;
    final isMember = currentUser != null && group.memberIds.contains(currentUser.uid);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Logo nhóm
                    _buildGroupLogo(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Hanken Grotesk',
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.people_outline, size: 16, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text(
                                '$memberCount thành viên',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  fontFamily: 'Hanken Grotesk',
                                ),
                              ),
                              if (group.location.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.location_on_outlined, size: 14, color: Colors.black38),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    group.location,
                                    style: const TextStyle(
                                      color: Colors.black38,
                                      fontSize: 12,
                                      fontFamily: 'Hanken Grotesk',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Badge trạng thái tham gia
              Container(
                decoration: BoxDecoration(
                  color: isMember
                      ? AppColors.primary.withOpacity(0.08)
                      : AppColors.buttonColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isMember
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.buttonColor.withOpacity(0.2),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      if (!isMember) {
                        GroupController.instance.joinGroup(group);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Text(
                        isMember ? 'Đã tham gia' : 'Tham gia',
                        style: TextStyle(
                          color: isMember ? AppColors.primary : AppColors.buttonColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'Hanken Grotesk',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (group.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              group.description,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontFamily: 'Hanken Grotesk',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          // Footer: privacy badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: group.isPublic
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      group.isPublic ? Icons.public : Icons.lock_outline,
                      size: 12,
                      color: group.isPublic
                          ? const Color(0xFF1565C0)
                          : const Color(0xFF6A1B9A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      group.isPublic ? 'Công khai' : 'Riêng tư',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: group.isPublic
                            ? const Color(0xFF1565C0)
                            : const Color(0xFF6A1B9A),
                      ),
                    ),
                  ],
                ),
              ),
              if (group.coverImageUrl.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupLogo() {
    if (group.logoImageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          group.logoImageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _defaultLogo(),
        ),
      );
    }
    return _defaultLogo();
  }

  Widget _defaultLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.buttonColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
