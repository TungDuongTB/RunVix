import 'package:runvix/export.dart';

class GroupController extends GetxController {
  static GroupController get instance => Get.find();

  final _groupRepo = Get.put(GroupRepository());
  final isLoading = false.obs;
  final isLoadingGroups = false.obs;
  final isLoadingSuggested = false.obs;
  final groups = <GroupModel>[].obs;
  final suggestedGroups = <GroupModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMyGroups();
      fetchSuggestedGroups();
    });
  }


  Future<void> fetchMyGroups() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    try {
      isLoadingGroups.value = true;
      final result = await _groupRepo.getGroupsCreatedByUser(currentUser.uid);
      groups.assignAll(result);
    } catch (e) {
      debugPrint('❌ fetchMyGroups error: $e');
    } finally {
      isLoadingGroups.value = false;
    }
  }

  /// Lấy danh sách nhóm đề xuất (công khai và user chưa tham gia)
  Future<void> fetchSuggestedGroups() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    try {
      isLoadingSuggested.value = true;
      final publicGroups = await _groupRepo.getPublicGroups();
      final result = publicGroups
          .where((group) => !group.memberIds.contains(currentUser.uid))
          .toList();
          
      suggestedGroups.assignAll(result);
    } catch (e) {
      debugPrint('❌ fetchSuggestedGroups error: $e');
    } finally {
      isLoadingSuggested.value = false;
    }
  }

  /// Tham gia nhóm
  Future<void> joinGroup(GroupModel group) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar('Lỗi', 'Vui lòng đăng nhập để tham gia nhóm.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (group.id == null || group.id!.isEmpty) return;

    try {
      isLoading.value = true;
      await _groupRepo.joinGroup(group.id!, currentUser.uid);
      
      // Tải lại danh sách
      await fetchMyGroups();
      await fetchSuggestedGroups();
      
      Get.snackbar(
        'Thành công 🎉',
        'Bạn đã tham gia nhóm "${group.name}"',
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


  Future<void> createGroup({
    required String name,
    required String description,
    required String location,
    required bool isPublic,
    required bool hasRequirements,
    required String minPace,
    required String minKm,
    required String minSessions,
    XFile? coverImageFile,
    XFile? logoImageFile,
  }) async {
    try {
      isLoading.value = true;

      // Lấy ID người dùng hiện tại
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Lỗi', 'Vui lòng đăng nhập để tạo nhóm.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Kiểm tra trùng tên nhóm trên Firebase
      final isTaken = await _groupRepo.isGroupNameTaken(name);
      if (isTaken) {
        Get.snackbar(
          'Tên nhóm đã tồn tại',
          'Nhóm "$name" đã có người sử dụng. Vui lòng chọn tên khác.',
          backgroundColor: const Color(0xFFFFF3E0),
          colorText: const Color(0xFFE65100),
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(Icons.group_off_outlined, color: Color(0xFFE65100)),
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // Upload ảnh cover nếu có
      String coverImageUrl = '';
      if (coverImageFile != null) {
        coverImageUrl = await _groupRepo.uploadImage(coverImageFile);
      }

      // Upload ảnh logo nếu có
      String logoImageUrl = '';
      if (logoImageFile != null) {
        logoImageUrl = await _groupRepo.uploadImage(logoImageFile);
      }

      // Tạo GroupModel
      final newGroup = GroupModel(
        name: name,
        description: description,
        location: location,
        coverImageUrl: coverImageUrl,
        logoImageUrl: logoImageUrl,
        isPublic: isPublic,
        hasRequirements: hasRequirements,
        minPace: minPace,
        minKm: minKm,
        minSessions: minSessions,
        creatorId: currentUser.uid,
        memberIds: [currentUser.uid],
        createdAt: DateTime.now(),
      );

      // Lưu lên Firestore
      await _groupRepo.createGroup(newGroup);

      // Refresh danh sách nhóm
      await fetchMyGroups();

      // Thông báo thành công và quay lại
      Get.back();
      Get.snackbar(
        'Thành công 🎉',
        "Đã tạo nhóm '$name' thành công!",
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
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
