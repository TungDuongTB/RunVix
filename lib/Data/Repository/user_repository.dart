import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../Model/user_model.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _db.collection("Users").doc(user.id).set(user.toJson()).catchError((error) {
      Get.snackbar("Lỗi", "Không thể lưu thông tin: $error", snackPosition: SnackPosition.BOTTOM);
    });
  }

  Future<UserModel> getUserDetails(String uid) async {
    try {
      final snapshot = await _db.collection("Users").doc(uid).get();
      if (snapshot.exists) {
        return UserModel.fromSnapshot(snapshot);
      } else {
        return UserModel.empty();
      }
    } catch (e) {
      throw 'Đã xảy ra lỗi khi lấy dữ liệu người dùng: $e';
    }
  }

  Future<void> updateUserRecord(UserModel user) async {
    await _db.collection("Users").doc(user.id).update(user.toJson());
  }

  Future<UserModel?> findUserByUsername(String username) async {
    try {
      // Tìm kiếm username (đã lưu dưới dạng lowercase)
      final snapshot = await _db
          .collection("Users")
          .where("Username", isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();
          
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromSnapshot(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint("Error finding user: $e");
      return null;
    }
  }

  /// Lấy tất cả người dùng từ Firestore
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _db.collection("Users").get();
      final allUsers = snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
      return allUsers;
    } catch (e) {
      throw 'Đã xảy ra lỗi khi lấy danh sách người dùng: $e';
    }
  }

  Future<void> followUser(String currentUserId, String otherUserId) async {
    try {
      await _db.collection("Followers").add({
        'uid': currentUserId,
        'ortherid': otherUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Lỗi khi theo dõi người dùng: $e';
    }
  }

  Future<void> unfollowUser(String currentUserId, String otherUserId) async {
    try {
      final snapshot = await _db
          .collection("Followers")
          .where('uid', isEqualTo: currentUserId)
          .where('ortherid', isEqualTo: otherUserId)
          .get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw 'Lỗi khi hủy theo dõi: $e';
    }
  }

  Future<List<String>> getFollowingIds(String uid) async {
    try {
      final snapshot = await _db.collection("Followers").where('uid', isEqualTo: uid).get();
      return snapshot.docs.map((doc) => doc.data()['ortherid'] as String).toList();
    } catch (e) {
      throw 'Lỗi khi lấy danh sách đang theo dõi: $e';
    }
  }

   Stream<List<String>> getFollowingStream(String uid) {
     return _db
         .collection("Followers")
         .where('uid', isEqualTo: uid)
         .snapshots()
         .map((snapshot) => snapshot.docs.map((doc) => (doc.data()['ortherid'] ?? "") as String).toList())
         .handleError((error) {
           debugPrint('❌ Error in following stream: $error');
           return <String>[];
         });
   }

  Future<List<String>> getFollowerIds(String uid) async {
    try {
      final snapshot = await _db.collection("Followers").where('ortherid', isEqualTo: uid).get();
      return snapshot.docs.map((doc) => doc.data()['uid'] as String).toList();
    } catch (e) {
      throw 'Lỗi khi lấy danh sách người theo dõi: $e';
    }
  }

   Stream<List<String>> getFollowerStream(String uid) {
     return _db
         .collection("Followers")
         .where('ortherid', isEqualTo: uid)
         .snapshots()
         .map((snapshot) => snapshot.docs.map((doc) => (doc.data()['uid'] ?? "") as String).toList())
         .handleError((error) {
           debugPrint('❌ Error in follower stream: $error');
           return <String>[];
         });
   }

  Future<bool> isFollowing(String currentUserId, String otherUserId) async {
    try {
      final snapshot = await _db
          .collection("Followers")
          .where('uid', isEqualTo: currentUserId)
          .where('ortherid', isEqualTo: otherUserId)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
