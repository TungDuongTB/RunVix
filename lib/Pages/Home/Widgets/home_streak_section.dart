import 'package:flutter/material.dart';

class HomeStreakSection extends StatelessWidget {
  const HomeStreakSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chuỗi liên tiếp của bạn',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Ghi ngay', style: TextStyle(color: Color(0xFFFF4500))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.local_fire_department, size: 48, color: Colors.grey.shade300),
                      const Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Text('Tuần', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDayCircle('T2', '6'),
                    _buildDayCircle('T3', '7', isToday: true),
                    _buildDayCircle('T4', '8'),
                    _buildDayCircle('T5', '9'),
                    _buildDayCircle('T6', '10'),
                    _buildDayCircle('T7', '11'),
                    _buildDayCircle('CN', '12'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == 0 ? Colors.black : Colors.grey.shade300,
              ),
            )),
          )
        ],
      ),
    );
  }

  Widget _buildDayCircle(String day, String date, {bool isToday = false}) {
    return Column(
      children: [
        Text(day, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade100,
            border: isToday ? Border.all(color: Colors.black, width: 1) : null,
          ),
          alignment: Alignment.center,
          child: Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
