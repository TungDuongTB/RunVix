import 'package:runvix/export.dart';

class MapRouteBottomSheet extends StatefulWidget {
  const MapRouteBottomSheet({super.key});

  @override
  State<MapRouteBottomSheet> createState() => _MapRouteBottomSheetState();
}

class _MapRouteBottomSheetState extends State<MapRouteBottomSheet> {
  final controller = Get.find<StravaController>();
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  static const double minSize = 0.22;
  static const double midSize = 0.6;
  static const double maxSize = 0.9;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: minSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: const [minSize, midSize, maxSize],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Column(
            children: [
              // Thanh kéo (Handle)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              Expanded(
                child: Obx(() {
                  if (controller.segments.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
                  }

                  final segments = controller.segments;
                  
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: segments.length + 1, // +1 cho nút "Xem thêm"
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == segments.length) {
                        return _buildSeeMoreButton();
                      }
                      
                      final segment = segments[index];
                      return RouteCard(
                        imageUrl: 'https://picsum.photos/140/140?random=$index',
                        title: segment['name'] ?? 'Không tên',
                        distance: '${((segment['distance'] ?? 0) / 1000).toStringAsFixed(2)} km',
                        elevation: '${segment['elev_difference'] ?? 0} m',
                        duration: '---',
                        difficulty: _getDifficulty(segment['average_grade'] ?? 0),
                        onTap: () {
                          controller.selectSegment(segment['id']);
                          // Khi chọn segment, thu nhỏ sheet lại hoặc làm gì đó
                          _sheetController.animateTo(
                            minSize,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeeMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextButton(
        onPressed: () {
          // Khi nhấn xem thêm, mở rộng sheet lên mức tối đa
          _sheetController.animateTo(
            maxSize,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: const Text(
          'Xem thêm cung đường',
          style: TextStyle(
            color: AppColors.buttonColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _getDifficulty(num grade) {
    if (grade.abs() < 2) return 'Dễ dàng';
    if (grade.abs() < 5) return 'Trung bình';
    return 'Thử thách';
  }
}
