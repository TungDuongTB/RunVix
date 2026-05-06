import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Nền bản đồ (Map Background)
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/1080/1920?grayscale',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Top UI: Badge Trends
          const RecordTopTrendsBadge(),

          // 3. Right UI: Floating Buttons
          const RecordFloatingButtons(),

          // 4. Bảng thông số Stats (GPS OK & Data)
          const RecordStatsCard(),

          // 5. Draggable Sheet (Controls & Settings)
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 12),
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2)))),
              const RecordControls(),
              const RecordAdvancedSettings(),
            ],
          ),
        );
      },
    );
  }
}
