import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Background Placeholder
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/1080/1920?grayscale',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Top Search & Filters
          const MapTopSearch(),

          // 3. Floating Action Buttons (Right Side)
          const MapFloatingButtons(),

          // 4. Bottom Info Card
          const MapRouteCard(),
        ],
      ),
    );
  }
}
