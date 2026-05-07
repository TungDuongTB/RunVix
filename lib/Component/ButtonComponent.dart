import 'package:flutter/cupertino.dart';

class ButtonComponent extends StatelessWidget {
  final String text;
  final double? width;
  final double? height;
  final Color? textColor;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final FontWeight textWeight;
  final VoidCallback? onPressed;

  const ButtonComponent({
    super.key,
    required this.text,
    this.width,
    this.height,
    this.textColor,
    this.color = CupertinoColors.systemPurple,
    this.borderColor = CupertinoColors.systemPurple,
    this.borderWidth = 0.0,
    this.borderRadius = 8.0,
    this.textWeight = FontWeight.bold, // default to bold
    this.onPressed,
  }) : assert(text != '');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(borderRadius),
        onPressed: onPressed,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? CupertinoColors.white,
              fontWeight: textWeight,
            ),
          ),
        ),
      ),
    );
  }
}
