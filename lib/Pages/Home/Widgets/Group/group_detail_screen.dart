import 'dart:ui';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:runvix/export.dart';
import 'Widgets/group_detail/group_detail_dialogs.dart';
import 'Widgets/group_detail/group_detail_events_section.dart';
import 'Widgets/group_detail/group_detail_hero_section.dart';
import 'Widgets/group_detail/group_detail_identity_section.dart';
import 'Widgets/group_detail/group_detail_posts_section.dart';
import 'Widgets/group_detail/group_detail_requirements_section.dart';
import 'Widgets/group_detail/group_detail_stats_section.dart';
import 'Widgets/group_detail/group_detail_terms_section.dart';
import 'Widgets/invite_friends_screen.dart';
import 'edit_group_screen.dart';
import 'edit_group_event_screen.dart';



class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late GroupModel _group;
  UserModel? _creator;
  bool _loadingCreator = true;
  List<ChallengeModel> _events = [];
  bool _loadingEvents = true;
  GroupWorkoutStats _workoutStats = GroupWorkoutStats.empty();
  bool _loadingStats = true;
  StreamSubscription<DocumentSnapshot>? _groupSubscription;

  GroupModel get group => _group;

  bool get _isMember {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && group.memberIds.contains(uid);
  }

  bool get _isCreator {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && uid == group.creatorId;
  }

  String get _creatorName {
    if (_creator == null) return 'Đang tải...';
    if (_creator!.fullName.isNotEmpty) return _creator!.fullName;
    if (_creator!.username.isNotEmpty) return _creator!.username;
    return 'Quản trị viên';
  }

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _loadCreator();
    _loadEvents();
    _loadWorkoutStats();
    _listenToGroupChanges();
  }

  void _listenToGroupChanges() {
    if (group.id == null || group.id!.isEmpty) return;
    _groupSubscription = FirebaseFirestore.instance
        .collection('Groups')
        .doc(group.id!)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        if (mounted) {
          Get.back();
          Get.snackbar(
            "Thông báo", 
            "Nhóm này đã bị giải tán.",
            
            backgroundColor: const Color(0xFFFFF3E0),
            colorText: const Color(0xFFE65100),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _groupSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCreator() async {
    if (group.creatorId.isEmpty) {
      setState(() => _loadingCreator = false);
      return;
    }

    try {
      final user = await UserRepository.instance.getUserDetails(
        group.creatorId,
      );
      if (mounted) setState(() => _creator = user);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingCreator = false);
    }
  }

  Future<void> _loadEvents() async {
    if (group.id == null || group.id!.isEmpty) {
      setState(() => _loadingEvents = false);
      return;
    }
    try {
      final events = await ChallengeRepository.instance.getGroupChallenges(group.id!);
      if (mounted) setState(() => _events = events);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingEvents = false);
    }
  }
  Future<void> _loadWorkoutStats() async {
    try {
      final stats = await WorkoutRepository.instance.getGroupWorkoutStats(group.memberIds);
      if (mounted) setState(() => _workoutStats = stats);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  void _openCreateEvent() {
    Get.to(
      () => CreateGroupEventScreen(group: group),
    )?.then((_) => _loadEvents());
  }

  Future<void> _joinGroup() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final joined = await GroupController.instance.joinGroup(group);
    if (!mounted || !joined) return;

    setState(() {
      _group = _group.copyWith(memberIds: [..._group.memberIds, uid]);
    });
    _loadWorkoutStats();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.groupBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: GroupDetailHeroSection(group: group)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GroupDetailIdentitySection(
                    group: group,
                    creatorName: _creatorName,
                    loadingCreator: _loadingCreator,
                  ),
                  if (!_isMember && !_isCreator) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _joinGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tham gia nhóm',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Hanken Grotesk'),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  GroupDetailStatsSection(
                    group: group,
                    eventCount: _events.length,
                    loadingStats: _loadingStats,
                    stats: _workoutStats,
                  ),
                  if (group.description.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    GroupDetailTermsSection(description: group.description),
                  ],
                  if (group.hasRequirements) ...[
                    const SizedBox(height: 32),
                    GroupDetailRequirementsSection(group: group),
                  ],
                  const SizedBox(height: 32),
                  GroupDetailEventsSection(
                    events: _events,
                    loading: _loadingEvents,
                    isCreator: _isCreator,
                    onAddEvent: _openCreateEvent,
                    onEventTapped: (challenge) {
                      if (_isCreator || FirebaseAuth.instance.currentUser?.uid == challenge.creatorId) {
                        Get.to(() => EditGroupEventScreen(group: group, challenge: challenge));
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  const GroupDetailPostsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.groupBackground.withOpacity(0.95),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.person_add_outlined, color: AppColors.buttonColor),
                onPressed: () {
                  Get.to(() => InviteFriendsScreen(group: group));
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.buttonColor),
                onPressed: () {
                  Get.to(() => EditGroupScreen(group: group));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: () => GroupDetailDialogs.confirmDeleteGroup(group),
              ),
            ],
          )
        else if (_isMember)
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.buttonColor),
            onPressed: () => GroupDetailDialogs.confirmLeaveGroup(group),
          ),
      ],
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
