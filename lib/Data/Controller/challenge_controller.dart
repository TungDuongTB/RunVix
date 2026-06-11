import 'dart:io';
import 'package:runvix/export.dart';
import 'package:image_picker/image_picker.dart';

class ChallengeController extends GetxController {
  static ChallengeController get instance => Get.find();

  final _challengeRepo = Get.put(ChallengeRepository());
  final _groupRepo = Get.put(GroupRepository());

  final RxBool isLoading = false.obs;
  final RxList<ChallengeModel> challenges = <ChallengeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    challenges.bindStream(_challengeRepo.streamChallenges());
  }

  /// Danh sách các thử thách đề xuất (Mỗi nhóm khác 1 thử thách mới nhất)
  List<ChallengeModel> get suggestedChallenges {
    // Lấy các nhóm hiện tại của user để loại trừ
    List<String> myGroupIds = [];
    if (Get.isRegistered<GroupController>()) {
      myGroupIds = GroupController.instance.groups.map((g) => g.id!).toList();
    }

    final grouped = <String, ChallengeModel>{};
    for (var challenge in challenges) {
      final gid = challenge.groupId;
      if (gid != null && gid.isNotEmpty) {
        // Chỉ lấy các thử thách của nhóm KHÁC nhóm của user
        if (!myGroupIds.contains(gid)) {
          // Do `challenges` đã được sort giảm dần theo StartDate (từ repo), 
          // nên thử thách đầu tiên gặp của mỗi group chính là thử thách mới nhất.
          if (!grouped.containsKey(gid)) {
            grouped[gid] = challenge;
          }
        }
      }
    }
    return grouped.values.toList();
  }

  /// Hàm tạo thử thách từ Group và gửi thông báo cho các thành viên
  Future<void> createChallengeFromGroup({
    required GroupModel group,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String type,
    required double goalValue,
    required String goalUnit,
    XFile? imageFile,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar('Lỗi', 'Vui lòng đăng nhập.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (group.id == null || group.id!.isEmpty) return;

    try {
      isLoading.value = true;

      String imageUrl = '';
      if (imageFile != null) {
        imageUrl = await _groupRepo.uploadImage(imageFile);
      }

      final challenge = ChallengeModel(
        groupId: group.id,
        creatorId: currentUser.uid,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        type: type,
        goalValue: goalValue,
        goalUnit: goalUnit,
        imageUrl: imageUrl,
      );

      final challengeId = await _challengeRepo.createChallenge(challenge);

      // Gửi thông báo đến tất cả thành viên của group
      final memberIds = group.memberIds.where((id) => id != currentUser.uid).toList();
      final NotificationRepository notificationRepo = NotificationRepository.instance;
      
      for (String memberId in memberIds) {
        await notificationRepo.createGroupChallengeNotification(
          memberId,
          currentUser.uid,
          group.id!,
          group.name,
          title,
        );
      }

      Get.back();
      Get.snackbar(
        'Thành công 🎉',
        'Đã tạo sự kiện/thử thách "$title"',
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cập nhật thử thách
  Future<void> updateChallenge({
    required ChallengeModel challenge,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    XFile? imageFile,
  }) async {
    if (challenge.id == null) return;
    try {
      isLoading.value = true;
      String imageUrl = challenge.imageUrl;
      if (imageFile != null) {
        imageUrl = await _groupRepo.uploadImage(imageFile);
      }

      final dataToUpdate = {
        'Title': title,
        'Description': description,
        'StartDate': startDate,
        'EndDate': endDate,
        'ImageUrl': imageUrl,
      };

      await _challengeRepo.updateChallenge(challenge.id!, dataToUpdate);
      
      Get.back();
      Get.snackbar(
        'Thành công 🎉',
        'Đã cập nhật sự kiện "$title"',
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Xóa thử thách
  Future<void> deleteChallenge(String challengeId) async {
    try {
      isLoading.value = true;
      await _challengeRepo.deleteChallenge(challengeId);
      Get.back(); // Quay lại sau khi xóa
      Get.snackbar(
        'Thành công',
        'Đã xóa sự kiện.',
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
