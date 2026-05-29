import 'package:flutter/material.dart';
import '../../../../Component/RouteCardComponent.dart';

class MapRouteCard extends StatelessWidget {
  const MapRouteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouteCard(
      imageUrl: 'https://picsum.photos/140/140',
      title: 'Đường Di Trạch-Đường Di Ái',
      distance: '6.40 km',
      elevation: '3 m',
      duration: '0 giờ 43 phút',
      difficulty: 'Dễ dàng',
      isTailored: true,
    );
  }
}
