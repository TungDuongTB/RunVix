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
    if (currentUser == null) {
      debugPrint('❌ fetchMyGroups: User không được xác thực');
      return;
    }
    try {
      isLoadingGroups.value = true;
      debugPrint('🔄 fetchMyGroups: Đang tải nhóm cho user ${currentUser.uid}');

      // Lấy nhóm mà user đã tham gia
      final userGroups = await _groupRepo.getGroupsByUser(currentUser.uid);
      debugPrint('✅ fetchMyGroups: Lấy được ${userGroups.length} nhóm user tham gia');

      // Lấy nhóm mà user tạo ra
      final createdGroups = await _groupRepo.getGroupsCreatedByUser(currentUser.uid);
      debugPrint('✅ fetchMyGroups: Lấy được ${createdGroups.length} nhóm user tạo');

      // Kết hợp cả hai list và loại bỏ duplicate dựa trên ID
      final allMyGroups = [...userGroups, ...createdGroups];
      final uniqueMap = <String, GroupModel>{};
      for (final group in allMyGroups) {
        if (group.id != null) {
          uniqueMap[group.id!] = group;
        }
      }

      final result = uniqueMap.values.toList();
      result.sort((a, b) {
        // Nhóm của user tạo luôn ở trên đầu
        final isACreator = a.creatorId == currentUser.uid;
        final isBCreator = b.creatorId == currentUser.uid;

        if (isACreator && !isBCreator) return -1;
        if (!isACreator && isBCreator) return 1;

        // Nếu cùng loại, sắp xếp theo ngày tạo mới nhất
        final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      groups.assignAll(result);
      debugPrint('✅ fetchMyGroups: Đã cập nhật ${result.length} nhóm');
    } catch (e) {
      debugPrint('❌ fetchMyGroups error: $e');
    } finally {
      isLoadingGroups.value = false;
    }
  }

   /// Lấy danh sách nhóm đề xuất (tất cả nhóm công khai - trừ nhóm user đã tham gia/tạo)
  Future<void> fetchSuggestedGroups() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    try {
      isLoadingSuggested.value = true;
      debugPrint('🔄 fetchSuggestedGroups: Đang tải các nhóm công khai');

      final publicGroups = await _groupRepo.getPublicGroups();
      debugPrint('✅ fetchSuggestedGroups: Lấy được ${publicGroups.length} nhóm công khai');

      // Filter bỏ những nhóm mà user đã tham gia hoặc tạo
      List<GroupModel> suggestedList = publicGroups;
      if (currentUser != null) {
        suggestedList = publicGroups
            .where((group) =>
                !group.memberIds.contains(currentUser.uid) &&
                group.creatorId != currentUser.uid)
            .toList();
        debugPrint('✅ fetchSuggestedGroups: Filter được ${suggestedList.length} nhóm (loại bỏ nhóm user tham gia/tạo)');
      }

      suggestedGroups.assignAll(suggestedList);
      debugPrint('✅ fetchSuggestedGroups: Đã cập nhật ${suggestedList.length} nhóm');
    } catch (e) {
      debugPrint('❌ fetchSuggestedGroups error: $e');
    } finally {
      isLoadingSuggested.value = false;
    }
  }

  /// Rời nhóm
  Future<void> leaveGroup(GroupModel group) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    if (group.id == null || group.id!.isEmpty) return;

    try {
      isLoading.value = true;
      await _groupRepo.leaveGroup(group.id!, currentUser.uid);
      await fetchMyGroups();
      await fetchSuggestedGroups();
      Get.back();
      Get.snackbar(
        'Đã rời nhóm',
        'Bạn đã rời khỏi nhóm "${group.name}"',
        backgroundColor: const Color(0xFFFFF3E0),
        colorText: const Color(0xFFE65100),
        
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Xóa nhóm (chỉ người tạo)
  Future<void> deleteGroup(GroupModel group) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    if (group.id == null || group.id!.isEmpty) return;
    if (group.creatorId != currentUser.uid) {
      Get.snackbar('Lỗi', 'Chỉ người tạo nhóm mới có thể xóa.',
          );
      return;
    }

    try {
      isLoading.value = true;
      
      // Lọc ra các thành viên khác để gửi thông báo
      final membersToNotify = group.memberIds.where((id) => id != currentUser.uid).toList();
      if (membersToNotify.isNotEmpty) {
        final notificationRepo = Get.put(NotificationRepository());
        await notificationRepo.createGroupDeletedNotification(membersToNotify, group.name);
      }

      // Xóa các sự kiện/thử thách thuộc về nhóm này
      final challengeRepo = Get.put(ChallengeRepository());
      await challengeRepo.deleteChallengesByGroupId(group.id!);

      await _groupRepo.deleteGroup(group.id!);
      await fetchMyGroups();
      await fetchSuggestedGroups();
      Get.back();
      Get.snackbar(
        'Đã xóa nhóm',
        'Nhóm "${group.name}" đã được xóa',
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
        
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        
      );
    } finally {
      isLoading.value = false;
    }
  }



  /// Tham gia nhóm
  Future<bool> joinGroup(GroupModel group) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar('Lỗi', 'Vui lòng đăng nhập để tham gia nhóm.',
          );
      return false;
    }
    
    if (group.id == null || group.id!.isEmpty) return false;

    try {
      isLoading.value = true;
      await _groupRepo.joinGroup(group.id!, currentUser.uid);
      
      await fetchMyGroups();
      await fetchSuggestedGroups();
      
      if (group.creatorId.isNotEmpty && group.creatorId != currentUser.uid) {
        final notificationRepo = Get.put(NotificationRepository());
        await notificationRepo.createGroupJoinNotification(
            group.creatorId, currentUser.uid, group.id!, group.name);
      }
      
      Get.snackbar(
        'Thành công 🎉',
        'Bạn đã tham gia nhóm "${group.name}"',
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
        
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Gửi lời mời bạn bè vào nhóm (bởi người tạo)
  Future<bool> sendGroupInvite(GroupModel group, String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;
    if (group.id == null || group.id!.isEmpty) return false;

    try {
      isLoading.value = true;
      final notificationRepo = Get.put(NotificationRepository());
      await notificationRepo.createGroupInviteNotification(
          userId, currentUser.uid, group.id!, group.name);
      
      Get.snackbar(
        'Đã gửi lời mời',
        'Đã gửi lời mời tham gia nhóm.',
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
        
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Thu hồi lời mời bạn bè vào nhóm
  Future<bool> revokeGroupInvite(GroupModel group, String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;
    if (group.id == null || group.id!.isEmpty) return false;

    try {
      isLoading.value = true;
      final notificationRepo = Get.put(NotificationRepository());
      await notificationRepo.deleteGroupInviteNotification(
          userId, currentUser.uid, group.id!);
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        
      );
      return false;
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
            );
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
        
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGroup({
    required GroupModel group,
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
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      if (group.id == null) return;

      // Kiểm tra trùng tên nhóm trên Firebase nếu tên thay đổi
      if (name.trim().toLowerCase() != group.name.trim().toLowerCase()) {
        final isTaken = await _groupRepo.isGroupNameTaken(name);
        if (isTaken) {
          Get.snackbar(
            'Tên nhóm đã tồn tại',
            'Nhóm "$name" đã có người sử dụng. Vui lòng chọn tên khác.',
            backgroundColor: const Color(0xFFFFF3E0),
            colorText: const Color(0xFFE65100),
            
            icon: const Icon(Icons.group_off_outlined, color: Color(0xFFE65100)),
            duration: const Duration(seconds: 4),
          );
          return;
        }
      }

      String coverImageUrl = group.coverImageUrl;
      if (coverImageFile != null) {
        coverImageUrl = await _groupRepo.uploadImage(coverImageFile);
      }

      String logoImageUrl = group.logoImageUrl;
      if (logoImageFile != null) {
        logoImageUrl = await _groupRepo.uploadImage(logoImageFile);
      }

      final data = {
        'Name': name,
        'Description': description,
        'Location': location,
        'CoverImageUrl': coverImageUrl,
        'LogoImageUrl': logoImageUrl,
        'IsPublic': isPublic,
        'HasRequirements': hasRequirements,
        'MinPace': minPace,
        'MinKm': minKm,
        'MinSessions': minSessions,
      };

      await _groupRepo.updateGroup(group.id!, data);

      await fetchMyGroups();

      Get.back(); // Quay lại trang chi tiết hoặc danh sách
      Get.snackbar(
        'Thành công 🎉',
        "Đã cập nhật nhóm '$name' thành công!",
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
        
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        
      );
    } finally {
      isLoading.value = false;
    }
  }
}
