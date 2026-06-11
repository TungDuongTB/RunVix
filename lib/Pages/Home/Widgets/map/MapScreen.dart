import 'package:runvix/export.dart';

class MapScreen extends GetView<StravaController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoadingLocation.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            Positioned.fill(
              child: Obx(() {
                final pos = controller.currentPosition.value;
                final polylinesSet = controller.polylines.toSet();

                return GoogleMap(
                  onMapCreated: controller.onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: pos != null
                        ? LatLng(pos.latitude, pos.longitude)
                        : const LatLng(21.0285, 105.8542),
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

            const Positioned(top: 0, left: 0, right: 0, child: MapTopSearch()),

            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height * 0.25,
              child: const MapFloatingButtons(),
            ),
            Obx(() {
              if (controller.selectedSegment.value != null) {
                return Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: const MapSegmentDetailCard(),
                );
              }
              return const MapRouteBottomSheet();
            }),
          ],
        );
      }),
    );
  }
}
