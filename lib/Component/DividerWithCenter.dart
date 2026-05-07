import 'package:flutter/cupertino.dart';

class DividerWithCenter extends StatelessWidget {
  final String? centerText;
  final Widget? center;
  final double thickness;
  final Color color;
  final double horizontalPadding;
  final double gap;

  const DividerWithCenter({
    super.key,
    this.centerText,
    this.center,
    this.thickness = 1.0,
    this.color = const Color(0xFFBDBDBD),
    this.horizontalPadding = 0.0,
    this.gap = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final Widget centerWidget = center ??
        (centerText != null
            ? Text(
                centerText!,
                style: TextStyle(
                  color: CupertinoColors.inactiveGray,
                  fontSize: 13,
                ),
              )
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          Expanded(child: Container(height: thickness, color: color)),
          SizedBox(width: gap),
          centerWidget,
          SizedBox(width: gap),
          Expanded(child: Container(height: thickness, color: color)),
        ],
      ),
    );
  }
}