import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:runvix/export.dart';
import '../Data/Controller/notification_controller.dart';
import '../Data/Model/notification_model.dart';

class NotificationDialog extends StatelessWidget {
  const NotificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.instance;
    final width = MediaQuery.of(context).size.width;
    final panelWidth = width < 300 ? width * 0.85 : 380.0;

    final panelHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: panelWidth,
        height: panelHeight,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(-8, 0),
              blurRadius: 24,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, controller),
                    const Divider(height: 1, color: AppColors.dividerGrey),
                    Expanded(
                      child: Obx(() {
                        if (controller.notifications.isEmpty) {
                          return _buildEmptyState();
                        }
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.notifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationItem(
                              context,
                              controller.notifications[index],
                              controller,
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotificationController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.buttonColor,
                  size: 24,
                ),
              ),
              Obx(() {
                if (controller.unreadCount.value > 0) {
                  return Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${controller.unreadCount.value}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          TextButton(
            onPressed: () => controller.markAllAsRead(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "Đọc tất cả",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.buttonColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo circle
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.buttonColor.withOpacity(0.1),
                    const Color(0xFFEFF6FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications,
                  color: AppColors.buttonColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Chưa có thông báo nào",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Khi có người theo dõi, thích hoặc\nbình luận bài viết, bạn sẽ thấy ở đây.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel item,
    NotificationController controller,
  ) {
    final senderId = item.senderIds.isNotEmpty ? item.senderIds.first : null;

    return FutureBuilder<UserModel>(
      future: senderId != null
          ? controller.getUserInfo(senderId)
          : Future.value(UserModel.empty()),
      builder: (context, snapshot) {
        final user = snapshot.data ?? UserModel.empty();
        final avatarUrl = user.profilePicture;
        final senderName = user.fullName.isNotEmpty
            ? user.fullName
            : "Người dùng RunVix";

        String text = "";
        IconData? icon;
        Color iconColor = Colors.grey;

        switch (item.type) {
          case "follow":
            text = "đã bắt đầu theo dõi bạn.";
            icon = Icons.person_add_outlined;
            iconColor = Colors.blue;
            break;
          case "follow_back":
            text = "đã theo dõi lại bạn.";
            icon = Icons.repeat;
            iconColor = Colors.purple;
            break;
          case "friend":
            text = "và bạn đã trở thành bạn bè.";
            icon = Icons.handshake_outlined;
            iconColor = Colors.green;
            break;
          case "like":
            if (item.senderIds.length == 1) {
              text = "đã thích bài viết của bạn.";
            } else {
              text =
                  "và ${item.senderIds.length - 1} người khác đã thích bài viết của bạn.";
            }
            icon = Icons.favorite;
            iconColor = Colors.red;
            break;
          case "comment":
            if (item.senderIds.length == 1) {
              text = "đã bình luận bài viết của bạn.";
            } else {
              text =
                  "và ${item.senderIds.length - 1} người khác đã bình luận bài viết của bạn.";
            }
            icon = Icons.chat_bubble_outline;
            iconColor = Colors.amber;
            break;
          case "system":
            text = item.body ?? "";
            icon = Icons.info_outline;
            iconColor = Colors.blueGrey;
            break;
        }

        final timeStr = item.createdAt != null
            ? _formatTimeAgo(item.createdAt!)
            : "";

        return InkWell(
          onTap: () {
            Navigator.pop(context); // Close the dialog
            controller.handleNotificationTap(item);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: item.isRead
                ? Colors.transparent
                : AppColors.buttonColor.withOpacity(0.04),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar representation
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundImage: avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : const AssetImage(
                                    'assets/Images/default_avatar.png',
                                  )
                                  as ImageProvider,
                      ),
                    ),
                    if (icon != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 12, color: iconColor),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Text representation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.3,
                            color: Colors.black87,
                          ),
                          children: [
                            if (item.type != "system")
                              TextSpan(
                                text: "$senderName ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            TextSpan(text: text),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!item.isRead)
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.buttonColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return "vừa xong";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} phút trước";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} giờ trước";
    } else {
      return intl.DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}
