import 'package:flutter/material.dart';
import 'package:runvix/Pages/Home/Widgets/Profile/activity_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:runvix/export.dart';

class ProfileActivitiesTab extends StatelessWidget {
  const ProfileActivitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.instance;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.workouts.isEmpty) {
        return const Center(child: Text("Chưa có hoạt động nào. Hãy bắt đầu chạy ngay!"));
      }

      return ListView.builder(
        itemCount: controller.workouts.length,
        itemBuilder: (context, index) {
          final workout = controller.workouts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.directions_run, color: Colors.orange),
              ),
              title: Text(
                DateFormat('dd/MM/yyyy - HH:mm').format(workout.timestamp),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${(workout.distance / 1000).toStringAsFixed(2)} km • ${workout.duration ~/ 60} phút • ${workout.averagePace.toStringAsFixed(2)} /km",
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.to(() => ActivityDetailScreen(workout: workout));
              },
            ),
          );
        },
      );
    });
  }
}
