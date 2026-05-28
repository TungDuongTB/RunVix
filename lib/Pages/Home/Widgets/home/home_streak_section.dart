import 'package:runvix/export.dart';

class HomeStreakSection extends StatelessWidget {
  const HomeStreakSection({super.key});

  @override
  Widget build(BuildContext context) {
    final calendarController = Get.put(CalendarController());
    
    // Tính toán các ngày trong tuần hiện tại
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    List<DateTime> weekDates = List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });

    final List<String> weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chuỗi liên tiếp của bạn',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () => NavigationController.instance.changeProfileTab(0),
                child: const Text(
                  'Xem lịch',
                  style: TextStyle(color: AppColors.buttonColor),
                ),
              ),

            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Obx(() => Icon(
                        Icons.local_fire_department, 
                        size: 48, 
                        color: calendarController.weeklyEvents.isNotEmpty ? Colors.orange : Colors.grey.shade300
                      )),
                      Obx(() => Text(
                        '${calendarController.weeklyEvents.length}', 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      )),
                    ],
                  ),
                  const Text('Tuần', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) {
                      DateTime date = weekDates[index];
                      bool isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                      bool hasEvent = calendarController.weeklyEvents.any((d) => 
                        d.day == date.day && d.month == date.month && d.year == date.year);
                      
                      return _buildDayCircle(
                        weekDays[index], 
                        date.day.toString(), 
                        isToday: isToday,
                        hasEvent: hasEvent,
                      );
                    }),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == 0 ? Colors.black : Colors.grey.shade300,
              ),
            )),
          ),
          Obx(() {
            if (calendarController.todayEvents.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Sự kiện hôm nay:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey),
                ),
                const SizedBox(height: 8),
                ...calendarController.todayEvents.map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayCircle(String day, String date, {bool isToday = false, bool hasEvent = false}) {
    return Column(
      children: [
        Text(day, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasEvent ? Colors.orange.withOpacity(0.2) : Colors.grey.shade100,
            border: isToday 
                ? Border.all(color: Colors.black, width: 1.5) 
                : (hasEvent ? Border.all(color: Colors.orange, width: 1) : null),
          ),
          alignment: Alignment.center,
          child: Text(
            date, 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w600,
              color: hasEvent ? Colors.orange.shade900 : Colors.black,
            )
          ),
        ),
      ],
    );
  }
}
