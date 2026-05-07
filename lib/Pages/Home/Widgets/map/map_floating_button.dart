import 'package:flutter/material.dart';

class MapFloatingButtons extends StatelessWidget {
  const MapFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        children: [
          _buildSideButton(const Text('B', style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          Stack(
            children: [
              _buildSideButton(const Icon(Icons.layers_outlined)),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 8)),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          _buildSideButton(const Text('3D', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          _buildSideButton(const Icon(Icons.my_location)),
          const SizedBox(height: 12),
          _buildSideButton(const Icon(Icons.edit_outlined)),
        ],
      ),
    );
  }

  Widget _buildSideButton(Widget icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Center(child: icon),
    );
  }
}
