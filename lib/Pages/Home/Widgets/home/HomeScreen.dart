import 'package:runvix/export.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userController = UserController.instance;
  final navigationController = NavigationController.instance;
  final postController = Get.put(PostController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // Khi cuộn gần đến cuối (cách đáy 200px), tải thêm bài viết
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        postController.loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> pagesWithScroll = [
      HomeContentBody(scrollController: _scrollController),
      const MapScreen(),
      const RecordScreen(),
      const GroupScreen(),
      const ProfileScreen(),
    ];

    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: IndexedStack(
        index: navigationController.selectedIndex.value,
        children: pagesWithScroll,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationController.selectedIndex.value,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.buttonColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) => navigationController.changeIndex(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Bản đồ'),
          BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked), label: 'Ghi lại'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Nhóm'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Bạn'),
        ],
      ),
    ));
  }
}

class HomeContentBody extends StatelessWidget {
  final ScrollController? scrollController;
  const HomeContentBody({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    
    return RefreshIndicator(
      onRefresh: () => PostController.instance.fetchPosts(),
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Obx(() {
                final user = userController.user.value;
                final networkImage = user.profilePicture;
                return CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: networkImage.isNotEmpty 
                      ? NetworkImage(networkImage) 
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  child: networkImage.isEmpty
                      ? const Icon(Icons.person, size: 18, color: Colors.grey) 
                      : null,
                );
              }),
              onPressed: () => Get.to(() => const ProfileDetailScreen()),
            ),
            title: const Text(
              'RUNVIX',
              style: TextStyle(
                color: AppColors.buttonColor, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                HomeStreakSection(),
                HomeSuggestedFollows(),
                HomeSuggestedChallenges(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
