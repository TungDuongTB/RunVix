import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class RecordControls extends StatelessWidget {
  const RecordControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildModeButton(Icons.directions_run, 'Chạy bộ'),
          _buildStartButton(),
          _buildRouteButton(Icons.add_location_alt_outlined, 'Thêm lộ trình'),
        ],
      ),
    );
  }

  Widget _buildModeButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange.shade200, width: 2),
          ),
          child: Icon(icon, color: Colors.orange.shade900, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildRouteButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
              color: Colors.grey.shade100, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black87, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStartButton() {
    return Column(
      children: [
        Container(
          width: 85,
          height: 85,
          decoration: const BoxDecoration(
            color: AppColors.buttonColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Color(0x66FF4500), blurRadius: 20, offset: Offset(0, 8))
            ],
          ),
          child: const Icon(Icons.play_arrow_rounded,
              color: Colors.white, size: 55),
        ),
        const SizedBox(height: 8),
        const Text('BẮT ĐẦU',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.buttonColor)),
      ],
    );
  }
}
