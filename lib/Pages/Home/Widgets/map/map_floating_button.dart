import 'package:flutter/material.dart';
import 'package:runvix/export.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapFloatingButtons extends GetView<StravaController> {
  const MapFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSideButton(
          const Text('B', style: TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            _buildSideButton(const Icon(Icons.layers_outlined), onTap: () {}),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSideButton(
          const Text(
            '3D',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildSideButton(
          const Icon(Icons.my_location),
          onTap: () async {
            final pos = controller.currentPosition.value;
            if (pos != null) {
              controller.mapController.animateCamera(
                CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
              );
            } else {
              await controller.determinePosition();
            }
          },
        ),
        const SizedBox(height: 12),
        _buildSideButton(const Icon(Icons.edit_outlined), onTap: () {}),
      ],
    );
  }

  Widget _buildSideButton(Widget icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }
}
