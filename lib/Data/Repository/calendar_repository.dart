import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'authentication_repository.dart';

class CalendarRepository {
  GoogleSignIn get _googleSignIn => AuthenticationRepository.instance.googleSignIn;

  Future<calendar.Events> getEventsForWeek(DateTime startOfWeek) async {
    try {
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) throw Exception("Chưa được xác thực Google");

      var calendarApi = calendar.CalendarApi(authClient);
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));
      
      return await calendarApi.events.list(
        'primary',
        timeMin: startOfWeek.toUtc(),
        timeMax: endOfWeek.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );
    } catch (e) {
      debugPrint('❌ Calendar Repository Error: $e');
      rethrow;
    }
  }

  Future<void> quickAddEvent(String text) async {
    try {
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) throw Exception("Chưa được xác thực Google");

      var calendarApi = calendar.CalendarApi(authClient);
      await calendarApi.events.quickAdd('primary', text);
      debugPrint('✅ Đã thêm sự kiện thành công');
    } catch (e) {
      debugPrint('❌ Calendar QuickAdd Error: $e');
      rethrow;
    }
  }
}
