import 'package:flutter/material.dart';

class Inputcomponent extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const Inputcomponent({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.emailAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1.5), // Khung màu xám bên ngoài
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Material(
        color: Colors.transparent, // Giữ màu của Container
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            // Loại bỏ border của InputDecoration vì đã có khung của Container
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}
