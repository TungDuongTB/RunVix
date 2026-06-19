import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class ChallengeTabContent extends StatelessWidget {
  const ChallengeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() {
              final challenges = ChallengeController.instance.challenges;
              if (challenges.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('Hiện chưa có thử thách nào.'),
                  ),
                );
              }
              return Column(
                children: challenges.map((challenge) => _buildChallengeCard(challenge)).toList(),
              );
            }),
          ),
          const SizedBox(height: 24),

        ],
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeModel challenge) {
    final start = '${challenge.startDate.day} thg ${challenge.startDate.month}';
    final end = '${challenge.endDate.day} thg ${challenge.endDate.month}, ${challenge.endDate.year}';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              challenge.imageUrl.isNotEmpty ? challenge.imageUrl : 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?q=80&w=400&auto=format&fit=crop',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                  image: DecorationImage(
                    image: NetworkImage(challenge.imageUrl.isNotEmpty ? challenge.imageUrl : 'https://picsum.photos/200'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.flash_on, size: 16, color: Colors.grey),
                        const Icon(Icons.emoji_events_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            challenge.description.isNotEmpty ? challenge.description : 'Thực hiện tổng cộng ${challenge.goalValue} ${challenge.goalUnit} ${challenge.type}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$start đến $end',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          '${challenge.joinedUserIds.length} người đã tham gia',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (FirebaseAuth.instance.currentUser?.uid != challenge.creatorId)
            Builder(
              builder: (context) {
                final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
                final isJoined = challenge.joinedUserIds.contains(uid);
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      ChallengeController.instance.toggleJoinChallenge(challenge);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isJoined ? Colors.grey.shade300 : AppColors.buttonColor,
                      foregroundColor: isJoined ? Colors.black87 : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),

                    child: Text(
                      isJoined ? 'Đã tham gia' : 'Tham gia',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              }
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
