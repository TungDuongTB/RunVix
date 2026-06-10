import 'package:runvix/export.dart';
import 'Widgets/create_group_banner.dart';
import 'Widgets/group_card.dart';

class GroupTabContent extends StatelessWidget {
  const GroupTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GroupController.instance;

    return RefreshIndicator(
      onRefresh: () => Future.wait([
        controller.fetchMyGroups(),
        controller.fetchSuggestedGroups(),
      ]),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Tìm kiếm nhóm...',
                    hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Hanken Grotesk'),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Banner tạo nhóm
              const CreateGroupBanner(),

              const SizedBox(height: 24),

              // SECTION 1: Nhóm của bạn
              const Text(
                'Nhóm của bạn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),

              const SizedBox(height: 12),

              Obx(() {
                if (controller.isLoadingGroups.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                if (controller.groups.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_off_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bạn chưa tạo nhóm nào',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontFamily: 'Hanken Grotesk',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.groups.map((group) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GroupCard(group: group),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 24),

              // SECTION 2: Đề xuất nhóm khác
              const Text(
                'Gợi ý nhóm cho bạn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),

              const SizedBox(height: 12),

              Obx(() {
                if (controller.isLoadingSuggested.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                if (controller.suggestedGroups.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Không có nhóm đề xuất mới nào',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontFamily: 'Hanken Grotesk',
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.suggestedGroups.map((group) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GroupCard(group: group),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
