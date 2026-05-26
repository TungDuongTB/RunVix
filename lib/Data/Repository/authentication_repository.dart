import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:get/get.dart';
import 'package:runvix/Component/ColorComponent.dart';
import 'package:runvix/Data/Model/user_model.dart';
import 'package:runvix/Data/Repository/user_repository.dart';
import 'package:runvix/Pages/Admin/admin_dashboard_screen.dart';
import 'package:runvix/Pages/Authen/LoginScreen.dart';
import 'package:runvix/Pages/Home/Widgets/home/HomeScreen.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _googleWebClientId = '827778185994-pg0hps23fiijpprfm1t5od5educniebt.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _googleWebClientId : null,
    scopes: [
      'email',
      calendar.CalendarApi.calendarScope,
      calendar.CalendarApi.calendarEventsScope,
    ],
  );

  // Getter để các repository khác dùng chung instance
  GoogleSignIn get googleSignIn => _googleSignIn;

  /// Kiểm tra và yêu cầu quyền Lịch (Phải được kích hoạt bởi hành động người dùng)
  Future<bool> ensureCalendarScopes() async {
    try {
      // Đảm bảo đã đăng nhập Google trước
      if (!await _googleSignIn.isSignedIn()) {
        final account = await _googleSignIn.signIn();
        if (account == null) return false;
      }

      final bool hasScopes = await _googleSignIn.canAccessScopes([
        calendar.CalendarApi.calendarScope,
        calendar.CalendarApi.calendarEventsScope,
      ]);

      if (hasScopes) return true;

      print("🔑 Đang yêu cầu thêm quyền Google Calendar...");
      return await _googleSignIn.requestScopes([
        calendar.CalendarApi.calendarScope,
        calendar.CalendarApi.calendarEventsScope,
      ]);
    } catch (e) {
      print("⚠️ Lỗi khi yêu cầu quyền: $e");
      return false;
    }
  }

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

  void _setInitialScreen(User? user) async {
    if (user?.uid == _lastProcessedUid) return;
    _lastProcessedUid = user?.uid;

    if (user == null) {
      if (Get.currentRoute != '/login') {
        Get.offAll(() => const Loginscreen());
      }
    } else {
      try {
        // Fetch user data to check role
        final userData = await UserRepository.instance.getUserDetails(user.uid);
        if (userData.role == 'admin' || userData.role == 'coordinator') {
          Get.offAll(() => const AdminDashboardScreen());
        } else {
          Get.offAll(() => const HomeScreen());
        }
      } catch (e) {
        print("Error fetching user role: $e");
        Get.offAll(() => const HomeScreen());
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      if (isLoading.value) return;
      isLoading.value = true;

      print("🌐 Đang gọi Google Sign-In...");
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) {
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
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
      Get.snackbar("Thông báo", "Lỗi đăng nhập Google", backgroundColor: AppColors.danger, colorText: Colors.white);
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

  // Các hàm login/register email giữ nguyên như cũ...
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Lỗi", e.message ?? "Đăng nhập thất bại", backgroundColor: AppColors.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithUsernameAndPassword(String username, String password) async {
    try {
      isLoading.value = true;
      final user = await UserRepository.instance.findUserByUsername(username.toLowerCase().trim());
      if (user == null) throw "Không tìm thấy người dùng";
      await _auth.signInWithEmailAndPassword(email: user.email, password: password);
    } catch (e) {
      Get.snackbar("Lỗi", e.toString(), backgroundColor: AppColors.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerWithEmailAndPassword(UserModel user, String password) async {
    try {
      isLoading.value = true;
      final userCredential = await _auth.createUserWithEmailAndPassword(email: user.email, password: password);
      if (userCredential.user != null) {
        final newUser = user.copyWith(id: userCredential.user!.uid);
        await UserRepository.instance.createUser(newUser);
        Get.snackbar("Thành công", "Tài khoản đã được tạo", backgroundColor: AppColors.success, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Lỗi", e.toString(), backgroundColor: AppColors.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
