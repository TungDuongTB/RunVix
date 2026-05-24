import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:runvix/Component/ColorComponent.dart';
import 'package:runvix/Data/Model/user_model.dart';
import 'package:runvix/Data/Repository/user_repository.dart';
import 'package:runvix/Pages/Authen/LoginScreen.dart';
import 'package:runvix/Pages/Home/Widgets/home/HomeScreen.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _googleWebClientId = '827778185994-pg0hps23fiijpprfm1t5od5educniebt.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _googleWebClientId : null,
  );

  late final Rx<User?> firebaseUser;
  final RxBool isLoading = false.obs;
  String? _lastProcessedUid;

  @override
  void onInit() {
    super.onInit();
    firebaseUser = Rx<User?>(null);
    _initializeFirebaseAuth();
  }

  void _initializeFirebaseAuth() {
    try {
      firebaseUser.value = _auth.currentUser;
      print("✅ Firebase initialized. Current user: ${firebaseUser.value?.email}");
    } catch (e) {
      print("❌ Firebase init error: $e");
    }
  }

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    if (user?.uid == _lastProcessedUid) return;
    _lastProcessedUid = user?.uid;

    if (user == null) {
      if (Get.currentRoute != '/login') {
        Get.offAll(() => const Loginscreen());
      }
    } else {
      if (Get.currentRoute != '/home') {
        Get.offAll(() => const HomeScreen());
      }
    }
  }

  /// ĐĂNG NHẬP VỚI GOOGLE
  Future<void> signInWithGoogle() async {
    try {
      if (isLoading.value) return; // Chặn bấm liên tục
      isLoading.value = true;

      print("🌐 Đang gọi Google Sign-In...");

      // 1. Thử đăng nhập im lặng trước (nếu đã từng đăng nhập)
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

      // 2. Nếu không được mới hiện Popup
      if (googleUser == null) {
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        print("⚠️ Người dùng đã đóng popup hoặc hủy.");
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      print("🎉 Đăng nhập thành công!");

    } catch (e) {
      print("❌ LỖI GOOGLE SIGN-IN: $e");

      String errorMsg = "Lỗi: $e";
      if (e.toString().contains("popup_closed")) {
        errorMsg = "Cửa sổ đăng nhập bị đóng. Vui lòng thử lại và không tắt cửa sổ giữa chừng.";
      }

      Get.snackbar(
          "Thông báo",
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: AppColors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Lỗi", e.message ?? "Đăng nhập thất bại",
          backgroundColor: AppColors.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithUsernameAndPassword(String username, String password) async {
    try {
      isLoading.value = true;
      
      // 1. Tìm email tương ứng với username (chuyển về lowercase)
      final user = await UserRepository.instance.findUserByUsername(username.toLowerCase().trim());
      
      if (user == null) {
        throw "Không tìm thấy người dùng với username này.";
      }

      // 2. Đăng nhập bằng email vừa tìm được
      await _auth.signInWithEmailAndPassword(email: user.email, password: password);
    } catch (e) {
      Get.snackbar("Lỗi", e.toString().replaceAll("Exception:", "").trim(),
          backgroundColor: AppColors.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerWithEmailAndPassword(UserModel user, String password) async {
    try {
      isLoading.value = true;
      
      final String cleanUsername = user.username.toLowerCase().trim();

      // 1. Kiểm tra username đã tồn tại chưa
      final existingUser = await UserRepository.instance.findUserByUsername(cleanUsername);
      if (existingUser != null) {
        throw "Username đã tồn tại. Vui lòng chọn username khác.";
      }

      // 2. Tạo user trong Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: user.email,
          password: password
      );

      if (userCredential.user != null) {
        // 3. Lưu thông tin bổ sung vào Firestore
        final newUser = UserModel(
          id: userCredential.user!.uid,
          username: cleanUsername, // Lưu dạng lowercase
          email: user.email,
          fullName: user.fullName,
          address: user.address,
          profilePicture: user.profilePicture,
        );

        await UserRepository.instance.createUser(newUser);

        Get.snackbar("Thành công", "Tài khoản của bạn đã được tạo!",
            backgroundColor: AppColors.success, colorText: Colors.white);
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Lỗi", e.message ?? "Đăng ký thất bại",
          backgroundColor: AppColors.danger, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Lỗi", e.toString(),
          backgroundColor: AppColors.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    _lastProcessedUid = null;
    await _googleSignIn.signOut();
    await _auth.signOut();
    Get.offAll(() => const Loginscreen());
  }
}
