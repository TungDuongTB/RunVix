import 'package:flutter/material.dart';

class Textfieldcomponent extends StatefulWidget {
  const Textfieldcomponent({super.key});

  @override
  State<Textfieldcomponent> createState() => _TextfieldcomponentState();
}


class _TextfieldcomponentState extends State<Textfieldcomponent> {
  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFBDBDBD);
    const focusedBorderColor = Color(0xFF888888);

    final minHeight =
        MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: TextField(
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        cursorColor: Colors.black,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'email@example.com',
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: focusedBorderColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
