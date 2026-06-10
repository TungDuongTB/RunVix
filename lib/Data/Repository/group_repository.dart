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
          .orderBy('CreatedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => GroupModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Không thể tải danh sách nhóm.';
    }
  }

  /// Lấy tất cả nhóm công khai
  Future<List<GroupModel>> getPublicGroups() async {
    try {
      final snapshot = await _db
          .collection('Groups')
          .where('IsPublic', isEqualTo: true)
          .orderBy('CreatedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => GroupModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Không thể tải danh sách nhóm.';
    }
  }
}
