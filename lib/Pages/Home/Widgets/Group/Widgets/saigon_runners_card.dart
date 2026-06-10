import 'package:runvix/export.dart' ;

class SaigonRunnersCard extends StatelessWidget {
  const SaigonRunnersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?q=80&w=200&auto=format&fit=crop',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saigon Runners',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Hanken Grotesk',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.people_outline, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '1,240 thành viên',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontFamily: 'Hanken Grotesk',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.buttonColor.withOpacity(0.2)),
                ),
                child: const Text(
                  'Hạng 1',
                  style: TextStyle(
                    color: AppColors.buttonColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Hanken Grotesk',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Tổng quãng đường',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        fontFamily: 'Hanken Grotesk',
                      ),
                    ),
                    Text(
                      '12,450 km',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Hanken Grotesk',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.buttonColor],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tuần này • +12% so với tuần trước',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    fontFamily: 'Hanken Grotesk',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
