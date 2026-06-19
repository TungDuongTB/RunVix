import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class ChangeEmailDialog extends StatefulWidget {
  const ChangeEmailDialog({super.key});

  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    final newEmail = _newEmailController.text.trim();
    final password = _passwordController.text.trim();

    if (newEmail.isEmpty || password.isEmpty) {
      Get.snackbar("Lỗi", "Vui lòng điền đầy đủ thông tin",
          backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updateEmail(newEmail);

        final userController = UserController.instance;
        final updatedUser = userController.user.value.copyWith(email: newEmail);
        await UserRepository.instance.updateUserRecord(updatedUser);
        userController.user.value = updatedUser;

        setState(() => _isSuccess = true);
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Không thể thay đổi email: ${e.message}";
      if (e.code == 'wrong-password') msg = "Mật khẩu hiện tại không đúng.";
      Get.snackbar("Lỗi", msg, backgroundColor: AppColors.danger, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Lỗi", "Có lỗi xảy ra: $e", backgroundColor: AppColors.danger, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEmail = UserController.instance.user.value.email;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
        ),
        padding: const EdgeInsets.all(24),
        child: _isSuccess ? _buildSuccessState() : _buildFormState(currentEmail),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(color: Color(0xFFE7F3EF), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: Color(0xFF00875A), size: 40),
        ),
        const SizedBox(height: 16),
        const Text('Đã thay đổi email!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF041B3C))),
        const SizedBox(height: 8),
        const Text(
          'Địa chỉ email của bạn đã được cập nhật thành công. Vui lòng kiểm tra hộp thư mới để xác minh.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF434654)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003D9B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Quay lại Cài đặt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildFormState(String currentEmail) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text('Đổi địa chỉ email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF041B3C))),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('Nhập địa chỉ email mới mà bạn muốn sử dụng.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF434654))),
        ),
        const SizedBox(height: 24),
        _buildLabel('Email hiện tại'),
        _buildTextField(initialValue: currentEmail, readOnly: true, prefixIcon: Icons.alternate_email),
        const SizedBox(height: 16),
        _buildLabel('Email mới'),
        _buildTextField(controller: _newEmailController, hintText: 'Nhập email mới...', prefixIcon: Icons.email_outlined),
        const SizedBox(height: 16),
        _buildLabel('Mật khẩu xác nhận'),
        _buildTextField(
          controller: _passwordController,
          hintText: 'Nhập mật khẩu hiện tại',
          obscureText: _obscurePassword,
          prefixIcon: Icons.key,
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF434654), size: 20),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _updateEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003D9B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Cập nhật', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF003D9B),
              side: const BorderSide(color: Color(0xFF003D9B)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF434654))),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    String? hintText,
    bool readOnly = false,
    bool obscureText = false,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC3C6D6).withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(prefixIcon, color: const Color(0xFF737685), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              initialValue: initialValue,
              readOnly: readOnly,
              obscureText: obscureText,
              style: TextStyle(fontSize: 16, color: readOnly ? const Color(0xFF434654) : const Color(0xFF041B3C)),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Color(0xFF737685), fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }
}
