import '../export.dart';

class AuthInputGroup extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const AuthInputGroup({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Inputcomponent(
          hintText: hintText,
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
