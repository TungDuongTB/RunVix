import 'package:flutter/cupertino.dart';

class Reponsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Reponsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 904;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 904 &&
      MediaQuery.of(context).size.width < 1280;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1280;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    if(size.width >= 1280) {
      return desktop;
    }
    else if(size.width >= 904 && tablet != null) {
      return tablet!;
    }
    else {
      return mobile;
    }
  }
}
