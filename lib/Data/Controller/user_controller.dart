import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:runvix/export.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final _userRepo = Get.put(UserRepository());
  final user = UserModel.empty().obs;
  final allUsers = <UserModel>[].obs;
  final isLoading = false.obs;
  final imageUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAllUsers();
    });
  }
  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (firebaseUser != null) {
          fetchUserRecord();
        } else {
          user.value = UserModel.empty();
          allUsers.clear();
        }
      });
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
      
      if (users.isEmpty) {
        allUsers.assignAll([
          UserModel(id: "1", username: "vankien", fullName: "Nguyễn Văn Kiên", email: "kien@gmail.com", address: "Hà Nội", profilePicture: "https://i.pravatar.cc/150?u=1"),
          UserModel(id: "2", username: "minhthu", fullName: "Trần Minh Thư", email: "thu@gmail.com", address: "HCM", profilePicture: "https://i.pravatar.cc/150?u=2"),
          UserModel(id: "3", username: "hoangnam", fullName: "Lê Hoàng Nam", email: "nam@gmail.com", address: "Đà Nẵng", profilePicture: "https://i.pravatar.cc/150?u=3"),
          UserModel(id: "4", username: "thuychi", fullName: "Phạm Thủy Chi", email: "chi@gmail.com", address: "Cần Thơ", profilePicture: "https://i.pravatar.cc/150?u=4"),
        ]);
      } else {
        allUsers.assignAll(users);
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi lấy tất cả user: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void followUser(String userId) {
    Get.snackbar("Thành công", "Đã gửi lời mời theo dõi!");
  }

  Future<String> uploadImage(XFile image) async {
    try {
      imageUploading.value = true;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/dz1z232l7/image/upload'),
      );
      request.fields['upload_preset'] = 'RunVix';
      final bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: image.name,
      ));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'];
      } else {
        debugPrint("Cloudinary Error: ${response.body}");
        final errorData = jsonDecode(response.body);
        throw errorData['error']['message'];
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
      throw "Lỗi khi tải ảnh lên: $e";
    } finally {
      imageUploading.value = false;
    }
  }

  Future<void> updateUserSettings(UserModel updatedUser) async {
    try {
      isLoading.value = true;
      await _userRepo.updateUserRecord(updatedUser);
      user.value = updatedUser;
      Get.back();
      Get.snackbar("Thành công", "Thông tin cá nhân đã được cập nhật");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cập nhật thông tin: $e");
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
          roles: {'user': true},
        );

        await _userRepo.createUser(newUser);
        user.value = newUser;
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu thông tin người dùng.");
    }
  }
}
