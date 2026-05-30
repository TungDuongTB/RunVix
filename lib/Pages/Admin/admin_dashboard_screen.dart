import 'package:runvix/export.dart' hide AdminStatsPanel, AdminUsersPanel, AdminContentPanel;
import 'admin_users_panel.dart';
import 'admin_content_panel.dart';
import 'admin_stats_panel.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<Widget> _panels = [
    const AdminStatsPanel(),
    const AdminUsersPanel(),
    const AdminContentPanel(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          // Sidebar
          if (Reponsive.isDesktop(context))
            NavigationRail(
              extended: true,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "RunVix Admin",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.buttonColor),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Thống kê'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Người dùng'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.library_books_outlined),
                  selectedIcon: Icon(Icons.library_books),
                  label: Text('Quản lý nội dung'),
                ),
              ],
            ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _panels,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: !Reponsive.isDesktop(context)
          ? Drawer(
              child: ListView(
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: AppColors.buttonColor),
                    child: Text("RunVix Admin", style: TextStyle(color: Colors.white, fontSize: 24)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Thống kê'),
                    onTap: () {
                      setState(() => _selectedIndex = 0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Người dùng'),
                    onTap: () {
                      setState(() => _selectedIndex = 1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.library_books),
                    title: const Text('Nội dung'),
                    onTap: () {
                      setState(() => _selectedIndex = 2);
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(context);
                      AuthenticationRepository.instance.logout();
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          if (!Reponsive.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),

          Expanded(
            child: Text(
              _selectedIndex == 0 ? "Thống kê hiệu suất" : _selectedIndex == 1 ? "Quản lý người dùng" : "Quản lý dữ liệu hệ thống",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            backgroundColor: AppColors.buttonColor,
            child: Icon(Icons.admin_panel_settings, color: Colors.white),
          ),
          const SizedBox(width: 12),
          if (Reponsive.isDesktop(context))
            const Text("Admin", style: TextStyle(fontWeight: FontWeight.bold)),
          if (Reponsive.isDesktop(context))
            const SizedBox(width: 16),
          IconButton(
            onPressed: () => AuthenticationRepository.instance.logout(),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Đăng xuất",
          ),
        ],
      ),
    );
  }
}
