import 'package:runvix/export.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final memberCount = group.memberIds.length;

    final currentUser = FirebaseAuth.instance.currentUser;
    final isMember = currentUser != null && group.memberIds.contains(currentUser.uid);
    final isCreator = currentUser != null && group.creatorId == currentUser.uid;

    return GestureDetector(
      onTap: () => Get.to(() => GroupDetailScreen(group: group)),
      child: GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover Image Header
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: group.coverImageUrl.isNotEmpty
                    ? Image.network(
                        group.coverImageUrl,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
                      )
                    : _buildDefaultCover(),
              ),
              // Badge "Nhóm của tôi" cho nhóm user tạo
              if (isCreator)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Nhóm của tôi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Hanken Grotesk',
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Card Body
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                                    const Icon(Icons.people_outline, size: 14, color: Colors.black54),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$memberCount thành viên',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                        fontFamily: 'Hanken Grotesk',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (group.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
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
                const SizedBox(height: 14),
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // _buildMemberAvatars(),
                    _buildWeeklyMileage(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFF070B19),
            Color(0xFF0F172A),
            Color(0xFFD97706), // Glowing gold
            Color(0xFF2563EB), // Glowing blue
            Color(0xFF0F172A),
          ],
          stops: [0.0, 0.25, 0.55, 0.8, 1.0],
        ),
      ),
    );
  }


  Widget _buildMemberAvatars() {
    final avatarColors = [
      const Color(0xFFF87171),
      const Color(0xFF60A5FA),
      const Color(0xFF34D399),
    ];

    int count = group.memberIds.length;
    if (count == 0) return const SizedBox.shrink();

    int displayCount = count > 3 ? 3 : count;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 28,
          width: (displayCount * 18.0) + 10,
          child: Stack(
            children: List.generate(displayCount, (index) {
              return Positioned(
                left: index * 16.0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: avatarColors[index % avatarColors.length],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (count > 3) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+${count - 3}',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF6B21A8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeeklyMileage() {
    final seed = group.name.hashCode.abs();
    final km = (seed % 3000) + 1500 + (group.memberIds.length * 150);
    final formattedKm = km.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return Text(
      '$formattedKm km tuần này',
      style: const TextStyle(
        fontStyle: FontStyle.italic,
        color: Colors.black54,
        fontSize: 12,
        fontFamily: 'Hanken Grotesk',
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
