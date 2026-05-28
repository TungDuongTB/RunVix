import 'package:runvix/export.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userController = UserController.instance;
  final navigationController = NavigationController.instance;

  final List<Widget> _pages = [
    const HomeContentBody(),
    const MapScreen(),
    const RecordScreen(),
    const GroupScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: navigationController.selectedIndex.value == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  'assets/Images/logo.jpg',
                  fit: BoxFit.contain,
                ),
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
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: IndexedStack(
        index: navigationController.selectedIndex.value,
        children: _pages,
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
  const HomeContentBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          HomeStreakSection(),
          HomeSuggestedFollows(),
          HomeSuggestedChallenges(),
        ],
      ),
    );
  }
}
