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

    return Container(
      color: Colors.white,
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
    );
  }
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Chuỗi liên tiếp của bạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        TextButton(
          onPressed: () => NavigationController.instance.changeProfileTab(0),
          child: const Text('Xem lịch', style: TextStyle(color: AppColors.buttonColor)),
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
            Obx(() => Icon(
              Icons.local_fire_department, 
              size: 48, 
              color: controller.streakCount.value > 0 ? Colors.orange : Colors.grey.shade300
            )),
            Obx(() => Text(
              '${controller.streakCount.value}', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
            )),
          ],
        ),
        const Text('Ngày', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 6, height: 6,
        decoration: BoxDecoration(shape: BoxShape.circle, color: index == 0 ? Colors.black : Colors.grey.shade300),
      )),
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
    return Column(
      children: [
        Text(day, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasEvent ? Colors.lightBlueAccent.withOpacity(0.2) : Colors.grey.shade100,
            border: isToday ? Border.all(color: Colors.black, width: 1.5) 
                   : (hasEvent ? Border.all(color: Colors.lightBlueAccent, width: 1) : null),
          ),
          alignment: Alignment.center,
          child: Text(date, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: hasEvent ? Colors.lightBlueAccent : Colors.black,
          )),
        ),
      ],
    );
  }
}


