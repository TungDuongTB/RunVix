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
}
