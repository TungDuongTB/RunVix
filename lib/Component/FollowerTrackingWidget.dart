import 'package:runvix/export.dart';

/// Widget hiển thị real-time tracking stats cho follower/following
class FollowerTrackingWidget extends StatelessWidget {
  const FollowerTrackingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;

    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Theo dõi Real-time',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBox(
                  context,
                  'Đang theo dõi',
                  () => userController.followingIds.length,
                  Icons.person_add,
                  Colors.blue,
                ),
                _buildStatBox(
                  context,
                  'Người theo dõi',
                  () => userController.followerIds.length,
                  Icons.people,
                  Colors.orange,
                ),
                _buildStatBox(
                  context,
                  'Tổng',
                  () => userController.followerIds.length + userController.followingIds.length,
                  Icons.group,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(
    BuildContext context,
    String label,
    int Function() getValue,
    IconData icon,
    Color color,
  ) {
    return Obx(() => Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          getValue().toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }
}


