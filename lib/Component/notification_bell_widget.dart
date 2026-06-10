import 'package:runvix/export.dart';

class NotificationBellWidget extends StatelessWidget {
  const NotificationBellWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.buttonColor,
              size: 26,
            ),
            onPressed: () {
              // Slide-in right aligned dialog
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: "Notifications",
                barrierColor: Colors.black.withOpacity(0.15),
                transitionDuration: const Duration(milliseconds: 250),
                pageBuilder: (context, anim1, anim2) {
                  return const NotificationDialog();
                },
                transitionBuilder: (context, anim1, anim2, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: anim1,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
              );
            },
          ),
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
