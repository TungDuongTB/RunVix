
import 'package:runvix/export.dart';

class CreateGroupBanner extends StatelessWidget {
  const CreateGroupBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.buttonColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xây dựng cộng đồng riêng?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Hanken Grotesk',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bắt đầu nhóm chạy của bạn và mời bạn bè tham gia ngay hôm nay.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              height: 1.4,
              fontFamily: 'Hanken Grotesk',
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => Get.to(() => const CreateGroupScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Tạo nhóm mới',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
