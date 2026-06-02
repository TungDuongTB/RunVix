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
      final todayList = <String>[];
      DateTime today = DateTime.now();
      
      // Tính toán khoảng thời gian tuần hiện tại (Thứ 2 - Chủ Nhật)
      DateTime startOfWeekDate = today.subtract(Duration(days: today.weekday - 1));
      DateTime startOfCurrentWeek = DateTime(startOfWeekDate.year, startOfWeekDate.month, startOfWeekDate.day);
      DateTime endOfCurrentWeek = startOfCurrentWeek.add(const Duration(days: 7));

      // --- PHẦN 1: LẤY WORKOUTS TỪ FIRESTORE (Luôn chạy nếu có User Firebase) ---
      final userId = AuthenticationRepository.instance.firebaseUser.value?.uid;
      if (userId != null) {
        try {
          final workouts = await _workoutRepo.getUserWorkouts(userId);
          for (var workout in workouts) {
            DateTime workoutDate = workout.timestamp;
            DateTime dayOnly = DateTime(workoutDate.year, workoutDate.month, workoutDate.day);
            
            if (dayOnly.isAfter(startOfCurrentWeek.subtract(const Duration(seconds: 1))) && 
                dayOnly.isBefore(endOfCurrentWeek)) {
              
              eventDates.add(dayOnly); // Set tự động loại bỏ ngày trùng
              
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
      // --- PHẦN 2: LẤY SỰ KIỆN TỪ GOOGLE CALENDAR (Chỉ khi đã đăng nhập & cấp quyền) ---
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
      
      // Bước 1: Đảm bảo quyền (Sẽ hiện Popup nếu cần)
      final hasPermission = await AuthenticationRepository.instance.ensureCalendarScopes();
      if (!hasPermission) {
        throw "Cần cấp quyền lịch để sử dụng tính năng này";
      }
      
      isAuthorized.value = true;

      // Bước 2: Gọi API
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
