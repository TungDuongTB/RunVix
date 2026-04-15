
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:runvix/Component/ButtonComponent.dart';

export '../export.dart';
class Loadingscreen extends StatelessWidget {
  const Loadingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter Demo',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemPurple,
    ),
    home:  Container(
    child: Center(
    child: ButtonComponent(text: 'Đăng nhập',height: 30,color: Colors.white,width: 150,textColor: Colors.black,onPressed: () {
      print('object');
    },),
    ),
    ),
    );
  }
}
