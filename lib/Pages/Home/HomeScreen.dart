import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContentBody(),
    const MapScreen(),
    const Center(child: Text('Ghi lại')),
    const Center(child: Text('Nhóm')),
    const Center(child: Text('Bạn')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage('https://picsum.photos/200'),
                ),
              ),
              title: const Text(
                'Trang chủ',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
                IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.black), onPressed: () {}),
                IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
              ],
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF4500),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Bản đồ'),
          BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked), label: 'Ghi lại'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Nhóm'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Bạn'),
        ],
      ),
    );
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
