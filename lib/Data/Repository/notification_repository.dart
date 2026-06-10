import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../Model/notification_model.dart';

class NotificationRepository extends GetxController {
  static NotificationRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  // Stream notifications for a specific user
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _db.collection("Notifications")
        .where("ReceiverId", isEqualTo: userId)
        .orderBy("CreatedAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromSnapshot(doc))
            .toList());
  }

  // Create or Update Like Notification (Grouped)
  Future<void> createOrUpdateLikeNotification(
      String receiverId, String senderId, String postId) async {
    if (receiverId == senderId) return; // Don't notify self
    try {
      final querySnapshot = await _db.collection("Notifications")
          .where("ReceiverId", isEqualTo: receiverId)
          .where("Type", isEqualTo: "like")
          .where("PostId", isEqualTo: postId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final notification = NotificationModel.fromSnapshot(doc);
        final senders = List<String>.from(notification.senderIds);
        
        // Remove duplicate if exists, and insert at front (most recent)
        senders.remove(senderId);
        senders.insert(0, senderId);

        await doc.reference.update({
          "SenderIds": senders,
          "IsRead": false,
          "CreatedAt": FieldValue.serverTimestamp(),
        });
      } else {
        final newNotification = NotificationModel(
          receiverId: receiverId,
          type: "like",
          senderIds: [senderId],
          postId: postId,
          isRead: false,
          createdAt: DateTime.now(),
        );
        await _db.collection("Notifications").add(newNotification.toJson());
      }
    } catch (e) {
      print("Error triggering like notification: $e");
    }
  }

  // Remove Like from Notification (when unlike occurs)
  Future<void> removeLikeNotification(
      String receiverId, String senderId, String postId) async {
    try {
      final querySnapshot = await _db.collection("Notifications")
          .where("ReceiverId", isEqualTo: receiverId)
          .where("Type", isEqualTo: "like")
          .where("PostId", isEqualTo: postId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final notification = NotificationModel.fromSnapshot(doc);
        final senders = List<String>.from(notification.senderIds);
        
        senders.remove(senderId);

        if (senders.isEmpty) {
          await doc.reference.delete();
        } else {
          await doc.reference.update({
            "SenderIds": senders,
          });
        }
      }
    } catch (e) {
      print("Error removing like notification: $e");
    }
  }

  // Create or Update Comment Notification (Grouped)
  Future<void> createOrUpdateCommentNotification(
      String receiverId, String senderId, String postId, String commentId) async {
    if (receiverId == senderId) return; // Don't notify self
    try {
      final querySnapshot = await _db.collection("Notifications")
          .where("ReceiverId", isEqualTo: receiverId)
          .where("Type", isEqualTo: "comment")
          .where("PostId", isEqualTo: postId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final notification = NotificationModel.fromSnapshot(doc);
        final senders = List<String>.from(notification.senderIds);

        senders.remove(senderId);
        senders.insert(0, senderId);

        await doc.reference.update({
          "SenderIds": senders,
          "CommentId": commentId,
          "IsRead": false,
          "CreatedAt": FieldValue.serverTimestamp(),
        });
      } else {
        final newNotification = NotificationModel(
          receiverId: receiverId,
          type: "comment",
          senderIds: [senderId],
          postId: postId,
          commentId: commentId,
          isRead: false,
          createdAt: DateTime.now(),
        );
        await _db.collection("Notifications").add(newNotification.toJson());
      }
    } catch (e) {
      print("Error triggering comment notification: $e");
    }
  }

  // Create Follow/FollowBack/Friend Notification
  Future<void> createFollowNotification(
      String receiverId, String senderId, String type) async {
    if (receiverId == senderId) return;
    try {
      // Remove any existing notifications of this exact type between A and B to avoid duplicates
      final querySnapshot = await _db.collection("Notifications")
          .where("ReceiverId", isEqualTo: receiverId)
          .where("Type", isEqualTo: type)
          .get();

      for (var doc in querySnapshot.docs) {
        final n = NotificationModel.fromSnapshot(doc);
        if (n.senderIds.contains(senderId)) {
          await doc.reference.delete();
        }
      }

      final newNotification = NotificationModel(
        receiverId: receiverId,
        type: type,
        senderIds: [senderId],
        isRead: false,
        createdAt: DateTime.now(),
      );
      await _db.collection("Notifications").add(newNotification.toJson());
    } catch (e) {
      print("Error triggering follow notification: $e");
    }
  }

  // Cleanup follow notifications (e.g. on unfollow)
  Future<void> deleteFollowNotifications(String receiverId, String senderId) async {
    try {
      final querySnapshot = await _db.collection("Notifications")
          .where("ReceiverId", isEqualTo: receiverId)
          .get();

      for (var doc in querySnapshot.docs) {
        final n = NotificationModel.fromSnapshot(doc);
        if ((n.type == "follow" || n.type == "follow_back" || n.type == "friend") &&
            n.senderIds.contains(senderId)) {
          await doc.reference.delete();
        }
      }

      // Also clean up reverse friend notification for the sender
      final reverseQuery = await _db.collection("Notifications")
          .where("ReceiverId", isEqualTo: senderId)
          .where("Type", isEqualTo: "friend")
          .get();

      for (var doc in reverseQuery.docs) {
        final n = NotificationModel.fromSnapshot(doc);
        if (n.senderIds.contains(receiverId)) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print("Error deleting follow notifications: $e");
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.collection("Notifications").doc(notificationId).update({
        "IsRead": true,
      });
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  // Mark all notifications of a user as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final querySnapshot = await _db.collection("Notifications")
          .where("ReceiverId", isEqualTo: userId)
          .where("IsRead", isEqualTo: false)
          .get();

      final batch = _db.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {"IsRead": true});
      }
      await batch.commit();
    } catch (e) {
      print("Error marking all notifications as read: $e");
    }
  }
}
