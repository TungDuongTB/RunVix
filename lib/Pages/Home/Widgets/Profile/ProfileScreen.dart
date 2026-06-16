import 'package:runvix/Pages/Home/Widgets/Profile/add_manual_activity_screen.dart';
import 'package:runvix/export.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final userController = UserController.instance;
  final navigationController = NavigationController.instance;
  Worker? _profileTabWorker;

  @override
  void initState() {
    super.initState();
    _initTabController();
  }

  void _initTabController() {
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: navigationController.profileTabIndex.value,
    );

    // Lắng nghe thay đổi từ controller (khi chuyển từ trang chủ)
    _profileTabWorker = ever(navigationController.profileTabIndex, (index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });

    // Cập nhật ngược lại controller khi người dùng vuốt tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        navigationController.profileTabIndex.value = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _profileTabWorker?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: const [ProfileProgressTab(), ProfileActivitiesTab()],
      ),
    );
  }

  /// Xây dựng AppBar sạch sẽ
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: _buildProfileAvatar(),
      title: const Text(
        'Bạn',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        _buildAddMenu(),
        IconButton(
          icon: const Icon(
            Icons.settings_outlined,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () => Get.to(() => SettingsScreen()),
        ),
      ],
      bottom: _buildTabBar(),
    );
  }

  /// Widget ảnh đại diện trên AppBar
  Widget _buildProfileAvatar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () => Get.to(() => const ProfileDetailScreen()),
        child: Obx(() {
          final networkImage = userController.user.value.profilePicture;
          return CircleAvatar(
            backgroundImage: NetworkImage(
              networkImage.isNotEmpty
                  ? networkImage
                  : 'https://picsum.photos/200',
            ),
          );
        }),
      ),
    );
  }

  /// Menu thêm mới (Popup ngay dưới nút Add)
  Widget _buildAddMenu() {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 28),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 4,
      onSelected: (value) {
        if (value == 0) {
          Get.to(() => const CreatePostScreen());
        } else if (value == 2) {
          Get.to(() => const AddManualActivityScreen());
        }
      },
      itemBuilder: (context) => [
        _buildPopupMenuItem(0, 'Đăng', Icons.article_outlined),
        const PopupMenuDivider(height: 1),
        _buildPopupMenuItem(2, 'Hoạt động thủ công', Icons.insights_outlined),
      ],
    );
  }

  /// Helper tạo item cho PopupMenu với Icon bên phải
  PopupMenuItem<int> _buildPopupMenuItem(
    int value,
    String text,
    IconData icon,
  ) {
    return PopupMenuItem<int>(
      value: value,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 15)),
          const SizedBox(width: 12),
          Icon(icon, color: Colors.black54, size: 22),
        ],
      ),
    );
  }

  /// Xây dựng TabBar
  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      indicatorColor: AppColors.buttonColor,
      indicatorWeight: 2,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      tabs: [
        const Tab(text: 'Tiến trình'),
        const Tab(text: 'Hoạt động'),
      ],
    );
  }
}
