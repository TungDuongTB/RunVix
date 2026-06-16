import 'package:runvix/export.dart';

class MapTopSearch extends StatelessWidget {
  const MapTopSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildSearchRow(),
          const SizedBox(height: 8),
          _buildFilterRow(context),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildIconCircle(Icons.directions_run),
          const SizedBox(width: 8),
          const Expanded(child: _SearchInput()),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Get.snackbar("Thông báo", "Chức năng đang được phát triển"),
            child: _buildSavedButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCircle(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.buttonColor),
    );
  }

  Widget _buildSavedButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.bookmark_border, size: 20),
          SizedBox(width: 4),
          Text('Đã lưu', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    final controller = StravaController.instance;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final distance = controller.selectedDistance.value;
        final isDistanceSelected = distance > 0;

        return Row(
          children: [
            AppFilterChip(
              label: 'Lộ trình',
              isSelected: true,
              hasDropdown: true,
              onTap: () => Get.snackbar("Thông báo", "Chức năng đang được phát triển"),
            ),
            AppFilterChip(
              label: isDistanceSelected
                  ? 'Độ dài: ${distance.round()} km+'
                  : 'Độ dài',
              isSelected: isDistanceSelected,
              hasDropdown: isDistanceSelected,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const MapDistanceFilterSheet(),
                );
              },
            ),
            AppFilterChip(
              label: 'Bề mặt',
              onTap: () => Get.snackbar("Thông báo", "Chức năng đang được phát triển"),
            ),
            AppFilterChip(
              label: 'Khó khăn',
              onTap: () => Get.snackbar("Thông báo", "Chức năng đang được phát triển"),
            ),
          ],
        );
      }),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput();

  @override
  Widget build(BuildContext context) {
    final controller = StravaController.instance;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onSubmitted: (value) => controller.searchLocation(value),
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm vị trí',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
