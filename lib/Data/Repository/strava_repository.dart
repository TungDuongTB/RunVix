import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class StravaRepository extends GetxService {
  static StravaRepository get instance => Get.find();

  final String _baseUrl = 'https://www.strava.com/api/v3';
  
  // Lấy các thông tin từ file .env
  String get _clientId => dotenv.env['STRAVA_CLIENT_ID'] ?? '';
  String get _clientSecret => dotenv.env['STRAVA_CLIENT_SECRET'] ?? '';
  String _accessToken = dotenv.env['STRAVA_ACCESS_TOKEN'] ?? '';
  String _refreshToken = dotenv.env['STRAVA_REFRESH_TOKEN'] ?? '';

  /// Làm mới Access Token khi hết hạn
  Future<String> refreshAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('https://www.strava.com/oauth/token'),
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'grant_type': 'refresh_token',
          'refresh_token': _refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        // Lưu ý: Trong thực tế bạn nên lưu lại token mới vào Storage (GetStorage hoặc SharedPreferences)
        return _accessToken;
      } else {
        throw Exception('Failed to refresh token: ${response.body}');
      }
    } catch (e) {
      print('Error refreshing Strava token: $e');
      return '';
    }
  }

  /// Tìm kiếm các đoạn đường (Segments) xung quanh một vị trí
  /// bounds: [southwest_lat, southwest_lng, northeast_lat, northeast_lng]
  Future<List<dynamic>> exploreSegments(List<double> bounds) async {
    try {
      final boundsStr = bounds.join(',');
      final response = await http.get(
        Uri.parse('$_baseUrl/segments/explore?bounds=$boundsStr&activity_type=running'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['segments'] ?? [];
      } else if (response.statusCode == 401) {
        // Token hết hạn, thử refresh và gọi lại
        await refreshAccessToken();
        return exploreSegments(bounds);
      } else {
        print('Error exploring segments: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception exploring segments: $e');
      return [];
    }
  }

  /// Lấy chi tiết một Segment cụ thể (bao gồm cả Polyline đầy đủ)
  Future<Map<String, dynamic>?> getSegmentDetails(int segmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/segments/$segmentId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await refreshAccessToken();
        return getSegmentDetails(segmentId);
      } else {
        print('Error getting segment details: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception getting segment details: $e');
      return null;
    }
  }

  /// Lấy bảng xếp hạng của một Segment
  Future<List<dynamic>> getSegmentLeaderboard(int segmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/segments/$segmentId/leaderboard'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['entries'] ?? [];
      } else if (response.statusCode == 401) {
        await refreshAccessToken();
        return getSegmentLeaderboard(segmentId);
      } else {
        print('Error getting segment leaderboard: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception getting segment leaderboard: $e');
      return [];
    }
  }
}
