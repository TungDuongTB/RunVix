import 'package:flutter/material.dart';
import 'package:runvix/export.dart';
import 'Widgets/saigon_runners_card.dart';
import 'Widgets/hanoi_morning_pace_card.dart';
import 'Widgets/elite_runners_dn_card.dart';
import 'Widgets/create_group_banner.dart';

class GroupTabContent extends StatelessWidget {
  const GroupTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Tìm kiếm nhóm...',
                  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Hanken Grotesk'),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recommendation Banner
            const CreateGroupBanner(),

            const SizedBox(height: 24),

            // Section Title & Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nhóm của bạn',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Hanken Grotesk',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Group List (Bento-style glass cards)
            Column(
              children: const [
                // Card 1: Saigon Runners
                SaigonRunnersCard(),
                SizedBox(height: 16),

                // Card 2: Hanoi Morning Pace
                HanoiMorningPaceCard(),
                SizedBox(height: 16),

                // Card 3: Elite Runners Da Nang
                EliteRunnersDnCard(),
              ],
            ),

            const SizedBox(height: 100), // Prevent overlap with bottom nav bar
          ],
        ),
      ),
    );
  }
}
