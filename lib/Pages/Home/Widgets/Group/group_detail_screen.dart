import 'dart:ui';
import 'package:runvix/export.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  static const _background = Color(0xFFFEF7FF);
  static const _onSurface = Color(0xFF1D1A25);
  static const _onSurfaceVariant = Color(0xFF4A4456);
  static const _outline = Color(0xFF7B7488);
  static const _secondary = Color(0xFF006687);
  static const _secondaryContainer = Color(0xFF00BEF9);

  bool _descriptionExpanded = false;
  UserModel? _creator;
  bool _loadingCreator = true;
  List<GroupEventModel> _events = [];
  bool _loadingEvents = true;

  GroupModel get group => widget.group;

  @override
  void initState() {
    super.initState();
    _loadCreator();
    _loadEvents();
  }

  Future<void> _loadCreator() async {
    if (group.creatorId.isEmpty) {
      setState(() => _loadingCreator = false);
      return;
    }
    try {
      final user = await UserRepository.instance.getUserDetails(group.creatorId);
      if (mounted) setState(() => _creator = user);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingCreator = false);
    }
  }

  bool get _isMember {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && group.memberIds.contains(uid);
  }

  bool get _isCreator {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && uid == group.creatorId;
  }

  Future<void> _loadEvents() async {
    if (group.id == null || group.id!.isEmpty) {
      setState(() => _loadingEvents = false);
      return;
    }
    try {
      final events = await GroupController.instance.fetchGroupEvents(group.id!);
      if (mounted) setState(() => _events = events);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingEvents = false);
    }
  }

  void _confirmDeleteGroup() {
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

  void _confirmLeaveGroup() {
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

  void _openCreateEvent() {
    Get.to(() => CreateGroupEventScreen(group: group))?.then((_) => _loadEvents());
  }

  String get _creatorName {
    if (_creator == null) return 'Đang tải...';
    if (_creator!.fullName.isNotEmpty) return _creator!.fullName;
    if (_creator!.username.isNotEmpty) return _creator!.username;
    return 'Quản trị viên';
  }

  @override
  Widget build(BuildContext context) {
    final memberCount = group.memberIds.length;
    final stats = _computeStats(memberCount);

    return Scaffold(
      backgroundColor: _background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: _background.withOpacity(0.95),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
              onPressed: () => Get.back(),
            ),
            title: Text(
              group.name,
              style: const TextStyle(
                color: AppColors.buttonColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: 'Hanken Grotesk',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            actions: [
              if (_isCreator)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  onPressed: _confirmDeleteGroup,
                )
              else if (_isMember)
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: AppColors.buttonColor),
                  onPressed: _confirmLeaveGroup,
                ),
            ],
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Hero
          SliverToBoxAdapter(
            child: SizedBox(
              height: 288,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: group.coverImageUrl.isNotEmpty
                        ? Image.network(
                            group.coverImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _defaultCover(),
                          )
                        : _defaultCover(),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            _background.withOpacity(0.3),
                            _background,
                          ],
                          stops: const [0.4, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: -40,
                    child: _buildAvatar(),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group identity
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _onSurface,
                      fontFamily: 'Hanken Grotesk',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: _outline),
                      const SizedBox(width: 6),
                      Text.rich(
                        TextSpan(
                          text: 'Quản trị viên: ',
                          style: const TextStyle(
                            color: _onSurfaceVariant,
                            fontSize: 14,
                            fontFamily: 'Hanken Grotesk',
                          ),
                          children: [
                            TextSpan(
                              text: _loadingCreator ? '...' : _creatorName,
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
                      _buildChip(
                        icon: group.isPublic ? Icons.public : Icons.lock_outline,
                        label: group.isPublic ? 'Công khai' : 'Riêng tư',
                        color: _secondary,
                        bgColor: _secondaryContainer.withOpacity(0.1),
                      ),
                      _buildChip(
                        icon: Icons.directions_run,
                        label: 'Chạy bộ',
                        color: AppColors.buttonColor,
                        bgColor: AppColors.buttonColor.withOpacity(0.1),
                      ),
                      if (group.location.isNotEmpty)
                        _buildChip(
                          icon: Icons.location_on_outlined,
                          label: group.location,
                          color: _onSurfaceVariant,
                          bgColor: const Color(0xFFF3EBFB),
                        ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.15,
                    children: [
                      _buildStatCard(
                        label: 'Thành viên',
                        value: '$memberCount',
                        subtitle: stats['weeklyMembers']!,
                        valueColor: _secondaryContainer,
                      ),
                      _buildStatCard(
                        label: 'Tổng quãng đường',
                        value: stats['totalKm']!,
                        subtitle: 'Kilometers',
                        valueColor: AppColors.buttonColor,
                      ),
                      _buildStatCard(
                        label: 'Tốc độ TB',
                        value: group.minPace.isNotEmpty ? group.minPace : stats['avgPace']!,
                        subtitle: 'min/km',
                        valueColor: _secondaryContainer,
                      ),
                      _buildStatCard(
                        label: 'Số sự kiện',
                        value: '${_events.length}',
                        subtitle: 'Sự kiện',
                        valueColor: AppColors.buttonColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Description / terms
                  if (group.description.isNotEmpty) ...[
                    GlassCard(
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
                                  color: _onSurface,
                                  fontFamily: 'Hanken Grotesk',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            group.description,
                            maxLines: _descriptionExpanded ? null : 3,
                            overflow: _descriptionExpanded ? null : TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _onSurfaceVariant,
                              fontSize: 14,
                              height: 1.5,
                              fontFamily: 'Hanken Grotesk',
                            ),
                          ),
                          if (group.description.length > 120)
                            GestureDetector(
                              onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _descriptionExpanded ? 'Thu gọn' : 'Xem thêm',
                                      style: const TextStyle(
                                        color: _secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: 'Hanken Grotesk',
                                      ),
                                    ),
                                    Icon(
                                      _descriptionExpanded ? Icons.expand_less : Icons.expand_more,
                                      color: _secondary,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Requirements
                  if (group.hasRequirements) ...[
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Yêu cầu tham gia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _onSurface,
                              fontFamily: 'Hanken Grotesk',
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (group.minPace.isNotEmpty)
                            _buildRequirementRow(Icons.speed, 'Pace tối thiểu: ${group.minPace}'),
                          if (group.minKm.isNotEmpty)
                            _buildRequirementRow(Icons.route, 'Km tối thiểu: ${group.minKm}'),
                          if (group.minSessions.isNotEmpty)
                            _buildRequirementRow(Icons.event, 'Buổi tập/tháng: ${group.minSessions}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Events section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sự kiện',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                          fontFamily: 'Hanken Grotesk',
                        ),
                      ),
                      if (_isCreator)
                        TextButton.icon(
                          onPressed: _openCreateEvent,
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text(
                            'Thêm sự kiện',
                            style: TextStyle(
                              color: _secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Hanken Grotesk',
                            ),
                          ),
                        )
                      else if (_events.isNotEmpty)
                        const Text(
                          'Tất cả',
                          style: TextStyle(
                            color: _secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Hanken Grotesk',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildEventsSection(),

                  const SizedBox(height: 32),

                  // Admin posts
                  const Text(
                    'Bài viết từ trưởng nhóm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _onSurface,
                      fontFamily: 'Hanken Grotesk',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEmptyPosts(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _computeStats(int memberCount) {
    final seed = group.name.hashCode.abs();
    final totalKm = ((seed % 15000) + 5000 + memberCount * 200) / 1000;
    final weeklyNew = (seed % 20) + 1;
    return {
      'weeklyMembers': '+$weeklyNew tuần này',
      'totalKm': '${totalKm.toStringAsFixed(1)}k',
      'avgPace': '${5 + (seed % 2)}:${(seed % 60).toString().padLeft(2, '0')}',
      'events': '${(seed % 30) + 1}',
    };
  }

  Widget _defaultCover() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFF070B19),
            Color(0xFF0F172A),
            Color(0xFFD97706),
            Color(0xFF2563EB),
            Color(0xFF0F172A),
          ],
          stops: [0.0, 0.25, 0.55, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _background, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: group.logoImageUrl.isNotEmpty
                ? Image.network(
                    group.logoImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _defaultLogo(),
                  )
                : _defaultLogo(),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _secondaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: _background, width: 2),
            ),
            child: const Icon(Icons.verified, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _defaultLogo() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.buttonColor, AppColors.buttonColor],
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
            fontSize: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
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

  Widget _buildStatCard({
    required String label,
    required String value,
    required String subtitle,
    required Color valueColor,
  }) {
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
              color: _onSurfaceVariant,
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
              color: _outline,
              fontSize: 11,
              fontFamily: 'Hanken Grotesk',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(IconData icon, String text) {
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
                color: _onSurfaceVariant,
                fontSize: 14,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    if (_loadingEvents) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.buttonColor)),
      );
    }

    if (_events.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            const Icon(Icons.event_busy_outlined, size: 40, color: _outline),
            const SizedBox(height: 8),
            Text(
              _isCreator ? 'Chưa có sự kiện nào. Hãy tạo sự kiện đầu tiên!' : 'Chưa có sự kiện nào',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _onSurfaceVariant,
                fontSize: 14,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
            if (_isCreator) ...[
              const SizedBox(height: 16),
              _buildAddEventButton(compact: true),
            ],
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => _buildEventCard(_events[index]),
      ),
    );
  }

  Widget _buildEventCard(GroupEventModel event) {
    final day = event.eventDate.day.toString().padLeft(2, '0');
    final month = 'Th${event.eventDate.month.toString().padLeft(2, '0')}';

    return SizedBox(
      width: 280,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  event.imageUrl.isNotEmpty
                      ? Image.network(event.imageUrl, fit: BoxFit.cover)
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.buttonColor, AppColors.primary],
                            ),
                          ),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            day,
                            style: const TextStyle(
                              color: AppColors.buttonColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            month.toUpperCase(),
                            style: const TextStyle(
                              color: _onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _onSurface,
                      fontFamily: 'Hanken Grotesk',
                    ),
                  ),
                  if (event.time.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: _onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          event.time,
                          style: const TextStyle(
                            color: _onSurfaceVariant,
                            fontSize: 13,
                            fontFamily: 'Hanken Grotesk',
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEventButton({bool compact = false}) {
    return OutlinedButton.icon(
      onPressed: _openCreateEvent,
      icon: const Icon(Icons.add, size: 18),
      label: Text(compact ? 'Thêm sự kiện' : 'Tạo sự kiện mới'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.buttonColor,
        side: BorderSide(color: AppColors.buttonColor.withOpacity(0.5)),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 24,
          vertical: compact ? 10 : 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }


  Widget _buildEmptyPosts() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: const [
          Icon(Icons.article_outlined, size: 40, color: _outline),
          SizedBox(height: 8),
          Text(
            'Chưa có bài viết từ trưởng nhóm',
            style: TextStyle(
              color: _onSurfaceVariant,
              fontSize: 14,
              fontFamily: 'Hanken Grotesk',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.buttonColor, AppColors.buttonColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => GroupController.instance.joinGroup(group),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            child: Text(
              'Tham gia nhóm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
