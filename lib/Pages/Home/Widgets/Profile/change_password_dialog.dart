import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _isLoading = false;
  int _strengthScore = 0;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateStrength(String value) {
    if (value.isEmpty) {
      setState(() {
        _strengthScore = 0;
      });
      return;
    }
    int score = 0;
    if (value.isNotEmpty) score++;
    if (value.length > 6) score++;
    if (value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[0-9]'))) score++;
    if (value.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    setState(() {
      _strengthScore = score;
    });
  }

  String get _strengthText {
    if (_newPasswordController.text.isEmpty) return "Độ mạnh mật khẩu";
    switch (_strengthScore) {
      case 1:
        return "Yếu";
      case 2:
        return "Trung bình";
      case 3:
        return "Mạnh";
      case 4:
        return "Rất mạnh";
      default:
        return "Độ mạnh mật khẩu";
    }
  }

  Color get _strengthColor {
    switch (_strengthScore) {
      case 1:
        return const Color(0xFFBA1A1A); // Red
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.yellow;
      case 4:
        return const Color(0xFF34C759); // Green
      default:
        return const Color(0xFFC5C6C8); // Grey
    }
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      Get.snackbar("Lỗi", "Vui lòng nhập mật khẩu hiện tại",
          backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }
    if (newPassword.length < 8) {
      Get.snackbar("Lỗi", "Mật khẩu mới tối thiểu phải có 8 ký tự",
          backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }
    if (newPassword != confirmPassword) {
      Get.snackbar("Lỗi", "Xác nhận mật khẩu mới không trùng khớp",
          backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        // Reauthenticate
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPassword);

        Get.snackbar("Thành công", "Đã đổi mật khẩu thành công!",
            backgroundColor: AppColors.success, colorText: Colors.white);
        Navigator.pop(context);
      } else {
        Get.snackbar("Lỗi", "Không xác định được người dùng đăng nhập",
            backgroundColor: AppColors.danger, colorText: Colors.white);
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException error: ${e.code}");
      String message = "Đã xảy ra lỗi khi đổi mật khẩu.";
      if (e.code == 'wrong-password') {
        message = "Mật khẩu hiện tại không đúng.";
      } else if (e.code == 'weak-password') {
        message = "Mật khẩu mới quá yếu.";
      } else if (e.code == 'user-mismatch' || e.code == 'user-not-found') {
        message = "Không tìm thấy thông tin tài khoản người dùng.";
      }
      Get.snackbar("Thất bại", message,
          backgroundColor: AppColors.danger, colorText: Colors.white);
    } catch (e) {
      print("General change password error: $e");
      Get.snackbar("Thất bại", "Mật khẩu hiện tại không chính xác hoặc đã xảy ra lỗi.",
          backgroundColor: AppColors.danger, colorText: Colors.white);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Đổi mật khẩu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF041B3C),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hãy nhập thông tin để bảo mật tài khoản của bạn.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF434654),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Form
            // Current Password
            const Text(
              'Mật khẩu hiện tại',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF434654),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrent,
                      decoration: const InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: Color(0xFFC3C6D6)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 16, color: Color(0xFF041B3C)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureCurrent = !_obscureCurrent;
                      });
                    },
                    child: Icon(
                      _obscureCurrent ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                      color: const Color(0xFF434654),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // New Password
            const Text(
              'Mật khẩu mới',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF434654),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      onChanged: _updateStrength,
                      decoration: const InputDecoration(
                        hintText: 'Tối thiểu 8 ký tự',
                        hintStyle: TextStyle(color: Color(0xFFC3C6D6)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 16, color: Color(0xFF041B3C)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureNew = !_obscureNew;
                      });
                    },
                    child: Icon(
                      _obscureNew ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                      color: const Color(0xFF434654),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Strength Bars
            Row(
              children: List.generate(4, (index) {
                final isColored = index < _strengthScore;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right: index < 3 ? 4 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isColored ? _strengthColor : const Color(0xFFE1E2E4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _strengthText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _newPasswordController.text.isNotEmpty && _strengthScore > 0
                      ? _strengthColor
                      : const Color(0xFF434654),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Confirm Password
            const Text(
              'Xác nhận mật khẩu mới',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF434654),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Nhập lại mật khẩu mới',
                  hintStyle: TextStyle(color: Color(0xFFC3C6D6)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF041B3C)),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003D9B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Cập nhật',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF003D9B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hủy',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
