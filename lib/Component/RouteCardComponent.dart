import 'package:flutter/material.dart';
import 'ColorComponent.dart';
import 'RouteStatsComponent.dart';

class RouteCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String distance;
  final String elevation;
  final String duration;
  final String difficulty;
  final String location;
  final bool isTailored;
  final VoidCallback? onTap;

  const RouteCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.distance,
    required this.elevation,
    required this.duration,
    required this.difficulty,
    this.location = 'Vị trí hiện tại',
    this.isTailored = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: Row(
          children: [
            _buildThumbnail(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    RouteStatsRow(
                      distance: distance,
                      elevation: elevation,
                      duration: duration,
                      difficulty: difficulty,
                    ),
                    const SizedBox(height: 8),
                    _buildLocationRow(),
                    const Spacer(),
                    if (isTailored) _buildTailoredTag(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: Image.network(
        imageUrl,
        width: 100,
        height: 140,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.disabled),
        const SizedBox(width: 4),
        Text(
          location,
          style: const TextStyle(fontSize: 12, color: AppColors.disabled),
        ),
      ],
    );
  }

  Widget _buildTailoredTag() {
    const orangeColor = Color(0xFFF57C00);
    return const Row(
      children: [
        Icon(Icons.auto_awesome, size: 14, color: orangeColor),
        SizedBox(width: 4),
        Text(
          'Được thiết kế riêng cho bạn',
          style: TextStyle(
            color: orangeColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
