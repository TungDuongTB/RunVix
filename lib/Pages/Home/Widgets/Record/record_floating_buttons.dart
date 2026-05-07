import 'package:flutter/material.dart';

class RecordFloatingButtons extends StatelessWidget {
  const RecordFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).size.height * 0.45,
      child: Column(
        children: [
          _buildCircleIcon(Icons.layers_outlined, badge: '2'),
          const SizedBox(height: 12),
          _buildCircleIcon(null, label: '3D'),
          const SizedBox(height: 12),
          _buildCircleIcon(Icons.my_location),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(IconData? icon, {String? label, String? badge}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: Colors.black, size: 22)
                : Text(label ?? '', style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
        if (badge != null)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle),
              child: Text(badge, style: const TextStyle(color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold)),
            ),
          )
      ],
    );
  }
}
