import 'package:flutter/material.dart';
import 'package:runvix/export.dart';

class ActionDialog extends StatelessWidget {
  final List<Widget> actions;
  final double? width;
  final double? height;
  final String title;

  const ActionDialog({
    super.key,
    required this.actions,
    this.width,
    this.height,
    this.title = 'Tạo mới',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.7,
        height: height,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            const Divider(),
            ...actions,
          ],
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    required List<Widget> actions,
    double? width,
    double? height,
    String? title,
  }) {
    showDialog(
      context: context,
      builder: (context) => ActionDialog(
        actions: actions,
        width: width,
        height: height,
        title: title ?? 'Tạo mới',
      ),
    );
  }
}
