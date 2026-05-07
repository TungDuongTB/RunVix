import 'package:flutter/material.dart';

class HomeSuggestedChallenges extends StatelessWidget {
  const HomeSuggestedChallenges({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thử thách gợi ý',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tập luyện kỷ luật, vui vẻ hơn và nhận thưởng!',
            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Text(
              'Hơn 33.000 vận động viên đã tham gia',
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}
