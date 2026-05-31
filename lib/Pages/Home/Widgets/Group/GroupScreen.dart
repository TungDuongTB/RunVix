import 'package:runvix/export.dart';

import 'challenge_tab_content.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1, // Mặc định ở tab "Câu lạc bộ"
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          title: const Text(
            'Nhóm',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.buttonColor,
            indicatorWeight: 3,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(text: 'Thử thách'),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Câu lạc bộ'),
                    SizedBox(width: 4),
                    CircleAvatar(backgroundColor: Colors.red, radius: 3),
                  ],
                ),
              ),
            ],
          ),

        ),
        body: const TabBarView(
          children: [
            ChallengeTabContent(),
            ClubTabContent(), // Sử dụng widget đã tách ra
          ],
        ),
      ),
    );
  }
}
