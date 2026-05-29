import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:runvix/export.dart';

class MapScreen extends GetView<StravaController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Hiển thị loading khi đang xác định vị trí ban đầu
        if (controller.isLoadingLocation.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // 1. Google Map - Tự động cập nhật khi polylines thay đổi
            Positioned.fill(
              child: Obx(() {
                final pos = controller.currentPosition.value;
                final polylinesSet = controller.polylines.toSet();

                return GoogleMap(
                  onMapCreated: controller.onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: pos != null
                        ? LatLng(pos.latitude, pos.longitude)
                        : const LatLng(21.0285, 105.8542), // Mặc định Hà Nội
                    zoom: 15.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  polylines: polylinesSet,
                  onCameraIdle: controller.fetchSegmentsInView,
                );
              }),
            ),

            // 2. Thanh tìm kiếm và bộ lọc phía trên (Đã tách widget)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MapTopSearch(),
            ),

            // 3. Các nút chức năng nổi phía bên phải (Đã tách widget)
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height * 0.25,
              child: const MapFloatingButtons(),
            ),

            // 4. Thẻ thông tin dưới cùng (Lộ trình hoặc Chi tiết đoạn đường)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Obx(() {
                if (controller.selectedSegment.value != null) {
                  return const MapSegmentDetailCard();
                }
                return const MapRouteCard();
              }),
            ),
          ],
        );
      }),
    );
  }
}
