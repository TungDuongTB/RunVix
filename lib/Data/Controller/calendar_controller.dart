import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../Repository/calendar_repository.dart';
import '../Repository/authentication_repository.dart';
import '../Repository/workout_repository.dart';

class CalendarController extends GetxController {
  static CalendarController get instance => Get.find();

  final _calendarRepo = CalendarRepository();
  final _workoutRepo = WorkoutRepository.instance;
  final isLoading = false.obs;
  final weeklyEvents = <DateTime>{}.obs;
  final todayEvents = <String>[].obs;
  final streakCount = 0.obs;
  final isAuthorized = false.obs;
  Timer? _debounce;
  // Biến khóa để ngăn chặn gọi API chồng chéo
  bool _isProcessing = false;

  @override
  void onInit() {
    super.onInit();
    // Không gọi fetch tự động nếu chưa chắc chắn về quyền để tránh lỗi "Future already completed"
    checkAuthorization(autoFetch: true);
  }

  // Hàm tính toán streak thực tế
  void _calculateStreak(Set<DateTime> allEventDates) {
    if (allEventDates.isEmpty) {
      streakCount.value = 0;
      return;
    }

    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    // Kiểm tra xem có hoạt động trong hôm nay hoặc hôm qua không
    bool activeToday = allEventDates.contains(today);
    bool activeYesterday = allEventDates.contains(yesterday);

    if (!activeToday && !activeYesterday) {
      streakCount.value = 0;
      return;
    }

    int count = 0;
    DateTime checkDate = activeToday ? today : yesterday;

    while (allEventDates.contains(checkDate)) {
      count++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    streakCount.value = count;
  }

  Future<void> checkAuthorization({bool autoFetch = false}) async {
    try {
      final googleSignIn = AuthenticationRepository.instance.googleSignIn;
      final bool alreadyHasScopes = await googleSignIn.canAccessScopes([
        'https://www.googleapis.com/auth/calendar',
        'https://www.googleapis.com/auth/calendar.events'
      ]);
      
      isAuthorized.value = alreadyHasScopes;
    } catch (e) {
      debugPrint("Auth check error: $e");
    } finally {
      if (autoFetch) {
        fetchCurrentWeekEvents();
      }
    }
  }

  Future<void> fetchCurrentWeekEvents() async {
    if (_isProcessing) return;
    
    try {
      _isProcessing = true;
      isLoading.value = true;
      
      final eventDates = <DateTime>{};
      final allHistoryDates = <DateTime>{}; // Dùng để tính streak dài hạn
      final todayList = <String>[];
      DateTime today = DateTime.now();
      
      DateTime startOfWeekDate = today.subtract(Duration(days: today.weekday - 1));
      DateTime startOfCurrentWeek = DateTime(startOfWeekDate.year, startOfWeekDate.month, startOfWeekDate.day);
      DateTime endOfCurrentWeek = startOfCurrentWeek.add(const Duration(days: 7));

      // --- PHẦN 1: LẤY WORKOUTS TỪ FIRESTORE ---
      final userId = AuthenticationRepository.instance.firebaseUser.value?.uid;
      if (userId != null) {
        try {
          final workouts = await _workoutRepo.getUserWorkouts(userId);
          for (var workout in workouts) {
            DateTime workoutDate = workout.timestamp;
            DateTime dayOnly = DateTime(workoutDate.year, workoutDate.month, workoutDate.day);
            
            allHistoryDates.add(dayOnly);

            if (dayOnly.isAfter(startOfCurrentWeek.subtract(const Duration(seconds: 1))) && 
                dayOnly.isBefore(endOfCurrentWeek)) {
              eventDates.add(dayOnly);
              
              if (dayOnly.year == today.year && dayOnly.month == today.month && dayOnly.day == today.day) {
                if (!todayList.contains("Hoạt động tập luyện")) {
                  todayList.add("Hoạt động tập luyện");
                }
              }
            }
          }
        } catch (e) {
          debugPrint("Error fetching workouts: $e");
        }
      }

      // --- PHẦN 2: LẤY SỰ KIỆN TỪ GOOGLE CALENDAR ---
      try {
        final googleSignIn = AuthenticationRepository.instance.googleSignIn;
        if (await googleSignIn.isSignedIn() && isAuthorized.value) {
          final events = await _calendarRepo.getEventsForWeek(startOfCurrentWeek);
          
          if (events.items != null) {
            for (var event in events.items!) {
              DateTime? date;
              if (event.start?.dateTime != null) {
                date = event.start!.dateTime!.toLocal();
              } else if (event.start?.date != null) {
                date = event.start!.date!;
              }

              if (date != null) {
                DateTime dayOnly = DateTime(date.year, date.month, date.day);
                allHistoryDates.add(dayOnly);
                eventDates.add(dayOnly);
                if (dayOnly.year == today.year && dayOnly.month == today.month && dayOnly.day == today.day) {
                  todayList.add(event.summary ?? "(Không có tiêu đề)");
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching calendar events: $e");
      }

      // Tính toán streak dựa trên toàn bộ lịch sử tìm thấy
      _calculateStreak(allHistoryDates);

      weeklyEvents.value = eventDates;
      todayEvents.value = todayList;
    } catch (e) {
      debugPrint("General error in fetchCurrentWeekEvents: $e");
    } finally {
      isLoading.value = false;
      _isProcessing = false;
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      if (query.isNotEmpty && query.length > 3) {
        addEventFromText(query);
      }
    });
  }

  Future<void> addEventFromText(String text) async {
    try {
      isLoading.value = true;
      
      final hasPermission = await AuthenticationRepository.instance.ensureCalendarScopes();
      if (!hasPermission) {
        throw "Cần cấp quyền lịch để sử dụng tính năng này";
      }
      
      isAuthorized.value = true;

      await _calendarRepo.quickAddEvent(text);
      await fetchCurrentWeekEvents();
      
      Get.snackbar("Thành công", "Đã thêm lịch: $text", 
        backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Lỗi", e.toString(), 
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
