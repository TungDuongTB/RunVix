import 'package:runvix/export.dart';

class ProfileStreakDistanceCards extends StatelessWidget {
  final int streakCount;
  final double totalDistance;

  const ProfileStreakDistanceCards({
    super.key,
    required this.streakCount,
    required this.totalDistance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Streak Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE4BFB1).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: AppColors.buttonColor,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STREAK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B4137),
                            letterSpacing: 1.0,
                            fontFamily: 'Geist',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$streakCount DAYS',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.buttonColor,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Total Distance Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE4BFB1).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map, color: AppColors.buttonColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL DIST.',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B4137),
                            letterSpacing: 1.0,
                            fontFamily: 'Geist',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${totalDistance.toStringAsFixed(1)} KM',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.buttonColor,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
