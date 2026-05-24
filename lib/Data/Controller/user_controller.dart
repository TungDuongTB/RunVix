import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Model/user_model.dart';
import '../Repository/user_repository.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final _userRepo = Get.put(UserRepository());
  final user = UserModel.empty().obs;
  final allUsers = <UserModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe sự thay đổi của Auth để tự động fetch dữ liệu
    _listenToAuthChanges();
    fetchAllUsers();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        debugPrint("🔄 Auth detected: Fetching user data for ${firebaseUser.uid}...");
        fetchUserRecord();
      } else {
        debugPrint("👤 Auth detected: No user logged in. Clearing data.");
        user.value = UserModel.empty();
      }
    });
  }

  Future<void> fetchUserRecord() async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData = await _userRepo.getUserDetails(currentUser.uid);
        
        if (userData != null) {
          user.value = userData;
          debugPrint("✅ Dữ liệu đã được lưu vào UserController: ${user.value.fullName}");
        } else {
          debugPrint("⚠️ Firestore không có dữ liệu cho UID này.");
        }
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi fetch user (kiểm tra Rules Firestore): $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllUsers() async {
    try {
      isLoading.value = true;
      final users = await _userRepo.getAllUsers();
      allUsers.assignAll(users);
    } catch (e) {
      debugPrint("❌ Lỗi khi lấy tất cả user: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveUserRecord(UserCredential? userCredential, {required String username, required String name, required String address}) async {
    try {
      if (userCredential != null) {
        final newUser = UserModel(
          id: userCredential.user!.uid,
          username: username,
          fullName: name,
          email: userCredential.user!.email ?? "",
          address: address,
          profilePicture: "https://picsum.photos/200",
        );

        await _userRepo.createUser(newUser);
        user.value = newUser;
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu thông tin người dùng.");
    }
  }
}
