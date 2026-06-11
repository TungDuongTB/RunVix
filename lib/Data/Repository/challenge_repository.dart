import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:runvix/export.dart';

class ChallengeRepository extends GetxController {
  static ChallengeRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Tạo một Challenge mới trên Firestore
  Future<String> createChallenge(ChallengeModel challenge) async {
    try {
      final docRef = await _db.collection('Challenges').add(challenge.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Đã xảy ra lỗi khi tạo thử thách. Vui lòng thử lại!';
    }
  }

  /// Lấy danh sách Challenge dạng Stream để cập nhật realtime
  Stream<List<ChallengeModel>> streamChallenges() {
    return _db
        .collection('Challenges')
        .orderBy('StartDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChallengeModel.fromSnapshot(doc))
            .toList());
  }

  /// Lấy toàn bộ Challenge (1 lần)
  Future<List<ChallengeModel>> getAllChallenges() async {
    try {
      final snapshot = await _db
          .collection('Challenges')
          .orderBy('StartDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ChallengeModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Không thể tải danh sách thử thách.';
    }
  }

  /// Lấy danh sách Challenge của một Group
  Future<List<ChallengeModel>> getGroupChallenges(String groupId) async {
    try {
      final snapshot = await _db
          .collection('Challenges')
          .where('GroupId', isEqualTo: groupId)
          .get();
      // Chú ý: Cần sort ở client nếu chưa có index
      final list = snapshot.docs
          .map((doc) => ChallengeModel.fromSnapshot(doc))
          .toList();
      list.sort((a, b) => b.startDate.compareTo(a.startDate));
      return list;
    } catch (e) {
      throw 'Không thể tải danh sách thử thách của nhóm.';
    }
  }

  /// Cập nhật thử thách
  Future<void> updateChallenge(String challengeId, Map<String, dynamic> data) async {
    try {
      await _db.collection('Challenges').doc(challengeId).update(data);
    } catch (e) {
      throw 'Đã xảy ra lỗi khi cập nhật thử thách.';
    }
  }

  /// Xóa thử thách
  Future<void> deleteChallenge(String challengeId) async {
    try {
      await _db.collection('Challenges').doc(challengeId).delete();
    } catch (e) {
      throw 'Đã xảy ra lỗi khi xóa thử thách.';
    }
  }
}
