import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:runvix/export.dart';

class GroupRepository extends GetxController {
  static GroupRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Kiểm tra xem tên nhóm đã tồn tại chưa (không phân biệt hoa thường)
  Future<bool> isGroupNameTaken(String name) async {
    try {
      final snapshot = await _db
          .collection('Groups')
          .where('Name', isEqualTo: name.trim().toLowerCase())
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      // Nếu lỗi query (ví dụ chưa có index), fallback về false để không chặn người dùng
      return false;
    }
  }

  /// Tạo nhóm mới trên Firestore
  Future<String> createGroup(GroupModel group) async {
    try {
      final docRef = await _db.collection('Groups').add(group.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Đã xảy ra lỗi khi tạo nhóm. Vui lòng thử lại!';
    }
  }

  /// Upload ảnh lên Cloudinary và trả về secure URL
  Future<String> uploadImage(XFile image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/dz1z232l7/image/upload'),
      );
      request.fields['upload_preset'] = 'RunVix';
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: image.name),
      );
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String;
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['error']['message'];
      }
    } catch (e) {
      throw 'Lỗi khi tải ảnh lên: $e';
    }
  }

   /// Lấy danh sách nhóm của một user
   Future<List<GroupModel>> getGroupsByUser(String userId) async {
     try {
       final snapshot = await _db
           .collection('Groups')
           .where('MemberIds', arrayContains: userId)
           .get();
       final list = snapshot.docs.map((doc) => GroupModel.fromSnapshot(doc)).toList();
       list.sort((a, b) {
         final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
         final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
         return dateB.compareTo(dateA);
       });
       return list;
     } catch (e) {
       print('❌ getGroupsByUser error: $e');
       throw 'Không thể tải danh sách nhóm: $e';
     }
   }

   /// Lấy tất cả nhóm công khai
   Future<List<GroupModel>> getPublicGroups() async {
     try {
       final snapshot = await _db
           .collection('Groups')
           .where('IsPublic', isEqualTo: true)
           .get();
       final list = snapshot.docs.map((doc) => GroupModel.fromSnapshot(doc)).toList();
       list.sort((a, b) {
         final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
         final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
         return dateB.compareTo(dateA);
       });
       return list;
     } catch (e) {
       print('❌ getPublicGroups error: $e');
       throw 'Không thể tải danh sách nhóm: $e';
     }
   }

   /// Lấy danh sách nhóm do một user tạo ra
   Future<List<GroupModel>> getGroupsCreatedByUser(String userId) async {
     try {
       final snapshot = await _db
           .collection('Groups')
           .where('CreatorId', isEqualTo: userId)
           .get();
       final list = snapshot.docs.map((doc) => GroupModel.fromSnapshot(doc)).toList();
       list.sort((a, b) {
         final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
         final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
         return dateB.compareTo(dateA);
       });
       return list;
     } catch (e) {
       print('❌ getGroupsCreatedByUser error: $e');
       throw 'Không thể tải danh sách nhóm do bạn tạo: $e';
     }
   }

  /// Tham gia vào một nhóm
  Future<void> joinGroup(String groupId, String userId) async {
    try {
      await _db.collection('Groups').doc(groupId).update({
        'MemberIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw 'Không thể tham gia nhóm: $e';
    }
  }

  /// Rời khỏi nhóm
  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      await _db.collection('Groups').doc(groupId).update({
        'MemberIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw 'Không thể rời nhóm: $e';
    }
  }

  /// Xóa nhóm và các sự kiện liên quan
  Future<void> deleteGroup(String groupId) async {
    try {
      final eventsSnapshot = await _db
          .collection('Groups')
          .doc(groupId)
          .collection('Events')
          .get();

      final batch = _db.batch();
      for (final doc in eventsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_db.collection('Groups').doc(groupId));
      await batch.commit();
    } catch (e) {
      throw 'Không thể xóa nhóm: $e';
    }
  }

  /// Lấy danh sách sự kiện của nhóm
  Future<List<GroupEventModel>> getGroupEvents(String groupId) async {
    try {
      final snapshot = await _db
          .collection('Groups')
          .doc(groupId)
          .collection('Events')
          .orderBy('EventDate')
          .get();
      return snapshot.docs
          .map((doc) => GroupEventModel.fromSnapshot(doc, groupId))
          .toList();
    } catch (e) {
      throw 'Không thể tải danh sách sự kiện.';
    }
  }

   /// Tạo sự kiện mới cho nhóm
   Future<String> createGroupEvent(GroupEventModel event) async {
     try {
       final docRef = await _db
           .collection('Groups')
           .doc(event.groupId)
           .collection('Events')
           .add(event.toJson());
       return docRef.id;
     } catch (e) {
       throw 'Không thể tạo sự kiện. Vui lòng thử lại!';
     }
   }

   /// Lấy tất cả các nhóm
   Future<List<GroupModel>> getAllGroups() async {
     try {
       final snapshot = await _db.collection('Groups').get();
       final list = snapshot.docs.map((doc) => GroupModel.fromSnapshot(doc)).toList();
       list.sort((a, b) {
         final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
         final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
         return dateB.compareTo(dateA);
       });
       return list;
     } catch (e) {
       throw 'Không thể tải tất cả các nhóm.';
     }
   }

   /// Lấy một nhóm theo ID
   Future<GroupModel?> getGroupById(String groupId) async {
     try {
       final snapshot = await _db.collection('Groups').doc(groupId).get();
       if (snapshot.exists) {
         return GroupModel.fromSnapshot(snapshot as DocumentSnapshot<Map<String, dynamic>>);
       }
       return null;
     } catch (e) {
       throw 'Không thể tải thông tin nhóm: $e';
     }
   }
 }
