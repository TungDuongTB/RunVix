import 'package:runvix/export.dart';

class RecordScreen extends GetView<RecordController> {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RecordController>()) {
      Get.put(RecordController());
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Lớp Bản đồ nền
          Positioned.fill(
            child: Obx(() {
              final pos = controller.currentPosition.value;
              final polylinesSet = controller.polylines;

              return GoogleMap(
                onMapCreated: controller.onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: pos != null
                      ? LatLng(pos.latitude, pos.longitude)
                      : const LatLng(21.0285, 105.8542),
                  zoom: 16.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                polylines: polylinesSet,
                padding: const EdgeInsets.only(bottom: 360),
              );
            }),
          ),

          // 2. Overlay: Nút chức năng bản đồ
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.my_location,
                  onPressed: () => controller.focusCurrentLocation(),
                ),
                const SizedBox(height: 12),
                _buildMapButton(
                  icon: Icons.layers,
                  onPressed: () {
                    // Logic chọn loại bản đồ
                  },
                ),
              ],
            ),
          ),
          // 3. Overlay: Bảng điều khiển & Thông số chạy (Đặt cố định phía trên bottomnav)
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildMapButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 96, // Hiển thị phía trên bottomnav (height 72 + margin 16 = 88)
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RecordStatsCard(),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: const RecordControls(),
          ),
        ],
      ),
    );
  }
}
