import 'package:flutter/material.dart';
import 'ColorComponent.dart';

class RouteStatsRow extends StatelessWidget {
  final String distance;
  final String elevation;
  final String duration;
  final String difficulty;
  final Color? difficultyColor;

  const RouteStatsRow({
    super.key,
    required this.distance,
    required this.elevation,
    required this.duration,
    required this.difficulty,
    this.difficultyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildDifficultyTag(),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$distance • $elevation • $duration',
            style: const TextStyle(fontSize: 11, color: AppColors.disabled),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyTag() {
    final color = difficultyColor ?? AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
