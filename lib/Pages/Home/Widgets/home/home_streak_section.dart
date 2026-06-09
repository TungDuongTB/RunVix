import 'package:runvix/export.dart';

class HomeStreakSection extends StatelessWidget {
  const HomeStreakSection({super.key});

  @override
  Widget build(BuildContext context) {
    final calendarController = Get.put(CalendarController());
    final DateTime now = DateTime.now();
    final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    final List<DateTime> weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    final List<String> weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: GlassCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFireStreak(calendarController),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) {
                      final date = weekDates[index];
                      return _DayCircle(
                        day: weekDays[index],
                        date: date.day.toString(),
                        isToday: date.day == now.day && date.month == now.month && date.year == now.year,
                        hasEvent: calendarController.weeklyEvents.any((d) => 
                          d.day == date.day && d.month == date.month && d.year == date.year),
                      );
                    }),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Chuỗi liên tiếp của bạn', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
        ),
        TextButton(
          onPressed: () => NavigationController.instance.changeProfileTab(0),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Xem lịch', style: TextStyle(color: AppColors.buttonColor, fontWeight: FontWeight.w600, fontSize: 13)),
              Icon(Icons.chevron_right, color: AppColors.buttonColor, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFireStreak(CalendarController controller) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Obx(() {
              final isActive = controller.streakCount.value > 0;
              if (isActive) {
                return ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 48,
                    color: Colors.white,
                  ),
                );
              } else {
                return Icon(
                  Icons.local_fire_department,
                  size: 48,
                  color: Colors.grey.shade300,
                );
              }
            }),
            Obx(() {
              final isActive = controller.streakCount.value > 0;
              return Positioned(
                bottom: 6,
                child: Text(
                  '${controller.streakCount.value}', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 13, 
                    color: isActive ? Colors.white : Colors.grey.shade600
                  )
                ),
              );
            }),
          ],
        ),
        const Text('Ngày', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _DayCircle extends StatelessWidget {
  final String day;
  final String date;
  final bool isToday;
  final bool hasEvent;

  const _DayCircle({required this.day, required this.date, this.isToday = false, this.hasEvent = false});

  @override
  Widget build(BuildContext context) {
    Color txtColor = Colors.grey.shade700;
    Widget childWidget = Text(date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
    
    BoxDecoration decoration = BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.2),
    );

    if (isToday) {
      txtColor = Colors.white;
      childWidget = Text(
        date, 
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: txtColor)
      );
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.buttonColor,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else if (hasEvent) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.buttonColor.withOpacity(0.1),
        border: Border.all(color: AppColors.buttonColor.withOpacity(0.2), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonColor.withOpacity(0.1),
            blurRadius: 6,
          )
        ],
      );
      childWidget = const Icon(
        Icons.check,
        size: 14,
        color: AppColors.buttonColor,
      );
    }

    return Column(
      children: [
        Text(
          day, 
          style: TextStyle(
            fontSize: 11, 
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? Colors.black87 : Colors.grey.shade600
          )
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: decoration,
          alignment: Alignment.center,
          child: childWidget,
        ),
      ],
    );
  }
}
