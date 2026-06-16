import 'package:runvix/export.dart';

class GroupDetailEventsSection extends StatelessWidget {
  final List<ChallengeModel> events;
  final bool loading;
  final bool isCreator;
  final VoidCallback onAddEvent;
  final Function(ChallengeModel) onEventTapped;

  const GroupDetailEventsSection({
    super.key,
    required this.events,
    required this.loading,
    required this.isCreator,
    required this.onAddEvent,
    required this.onEventTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sự kiện',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
            if (isCreator)
              TextButton.icon(
                onPressed: onAddEvent,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text(
                  'Thêm sự kiện',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Hanken Grotesk',
                  ),
                ),
              )
            else if (events.isNotEmpty)
              const Text(
                'Tất cả',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.buttonColor)),
      );
    }

    if (events.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            const Icon(Icons.event_busy_outlined, size: 40, color: AppColors.outline),
            const SizedBox(height: 8),
            Text(
              isCreator ? 'Chưa có sự kiện nào. Hãy tạo sự kiện đầu tiên!' : 'Chưa có sự kiện nào',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                fontFamily: 'Hanken Grotesk',
              ),
            ),

          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => GroupDetailEventCard(
          event: events[index],
          onTap: () => onEventTapped(events[index]),
        ),
      ),
    );
  }
}

class GroupDetailEventCard extends StatelessWidget {
  final ChallengeModel event;
  final VoidCallback onTap;

  const GroupDetailEventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final day = event.startDate.day.toString().padLeft(2, '0');
    final month = 'Th${event.startDate.month.toString().padLeft(2, '0')}';

    return SizedBox(
      width: 280,
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  event.imageUrl.isNotEmpty
                      ? Image.network(event.imageUrl, fit: BoxFit.cover)
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.buttonColor, AppColors.primary],
                            ),
                          ),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            day,
                            style: const TextStyle(
                              color: AppColors.buttonColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            month.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                      fontFamily: 'Hanken Grotesk',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                          fontFamily: 'Hanken Grotesk',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${event.joinedUserIds.length} người tham gia',
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                          fontFamily: 'Hanken Grotesk',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}


