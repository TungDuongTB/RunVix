import 'dart:ui';
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
      backgroundColor: const Color(0xFFF9F9F9),
      body: CustomPaint(
        painter: RadialGradientPainter(),
        child: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: navigationController.selectedIndex.value,
                children: pagesWithScroll,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildCustomBottomNavBar(),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildCustomBottomNavBar() {
    final tabs = [
      {'icon': Icons.home, 'label': 'Trang chủ'},
      {'icon': Icons.map_outlined, 'label': 'Bản đồ'},
      {'icon': Icons.radio_button_checked, 'label': 'Ghi lại'},
      {'icon': Icons.group_outlined, 'label': 'Nhóm'},
      {'icon': Icons.person_outline, 'label': 'Bạn'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF).withOpacity(0.4), // soft translucent blue tint
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0062FF).withOpacity(0.05),
            offset: const Offset(0, 8),
            blurRadius: 32,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final isSelected = navigationController.selectedIndex.value == index;
                if (index == 2) {
                  // Ghi lại (Record) - Circular floating button
                  return GestureDetector(
                    onTap: () => navigationController.changeIndex(index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.buttonColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.buttonColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ]
                            ),
                            child: const Icon(
                              Icons.fiber_manual_record,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -6),
                          child: Text(
                            tabs[index]['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.buttonColor : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => navigationController.changeIndex(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tabs[index]['icon'] as IconData,
                          color: isSelected ? AppColors.buttonColor : Colors.grey.shade600,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tabs[index]['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.buttonColor : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
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
            backgroundColor: Colors.white.withOpacity(0.4),
            elevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                child: Container(color: Colors.transparent),
              ),
            ),
            leading: IconButton(
              icon: Obx(() {
                final user = userController.user.value;
                final networkImage = user.profilePicture;
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.buttonColor.withOpacity(0.2), width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: networkImage.isNotEmpty 
                        ? NetworkImage(networkImage) 
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    child: networkImage.isEmpty
                        ? const Icon(Icons.person, size: 18, color: Colors.grey) 
                        : null,
                  ),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: AppColors.buttonColor),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                HomeStreakSection(),
                HomeSuggestedFollows(),
                HomeSuggestedChallenges(),
                SizedBox(height: 100), // padding to prevent content overlap with floating bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RadialGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF0062FF).withOpacity(0.08), Colors.transparent],
        center: Alignment.topLeft,
        radius: 0.8,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF0062FF).withOpacity(0.08), Colors.transparent],
        center: Alignment.topRight,
        radius: 0.8,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);

    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF0062FF).withOpacity(0.08), Colors.transparent],
        center: Alignment.bottomLeft,
        radius: 0.8,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint3);

    final paint4 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF0062FF).withOpacity(0.08), Colors.transparent],
        center: Alignment.bottomRight,
        radius: 0.8,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
