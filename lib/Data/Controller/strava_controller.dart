import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import '../Repository/strava_repository.dart';
import 'navigation_controller.dart';

class StravaController extends GetxController {
  static StravaController get instance => Get.find();

  final _stravaRepo = StravaRepository.instance;
  
  // Bản đồ & Vị trí
  late GoogleMapController mapController;
  var currentPosition = Rxn<Position>();
  var isLoadingLocation = true.obs;
  final searchController = TextEditingController();
  
  var segments = <dynamic>[].obs;
  var allSegments = <dynamic>[].obs; // Lưu trữ tất cả để lọc
  var isLoading = false.obs;
  var polylines = <Polyline>{}.obs;
  
  // Filters
  var selectedDistance = 0.0.obs;
  
  var selectedSegment = Rxn<dynamic>();
  var selectedSegmentLeaderboard = <dynamic>[].obs;
  var isLoadingDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
    
    // Lắng nghe thay đổi khoảng cách để lọc lại và focus
    ever(selectedDistance, (_) => applyFilters(shouldFocus: true));
  }

  @override
  void onClose() {
    searchController.dispose();
    NavigationController.instance.setBottomNavBarVisible(true);
    super.onClose();
  }

  /// Lọc các đoạn đường dựa trên khoảng cách
  void applyFilters({bool shouldFocus = false}) {
    if (selectedDistance.value == 0) {
      segments.assignAll(allSegments);
    } else {
      segments.assignAll(allSegments.where((s) {
        final distanceKm = (s['distance'] ?? 0) / 1000;
        return distanceKm >= selectedDistance.value;
      }).toList());
    }
    _updatePolylinesFromSegments();
    
    // Chỉ focus nếu được yêu cầu (ví dụ: khi người dùng thay đổi bộ lọc)
    if (shouldFocus && segments.isNotEmpty && currentPosition.value != null) {
      focusNearestSegment();
    }
  }

  void focusNearestSegment() {
    if (segments.isEmpty || currentPosition.value == null) return;

    dynamic nearest;
    double minDistance = double.infinity;

    for (var segment in segments) {
      final startLatLng = segment['start_latlng'];
      if (startLatLng != null && startLatLng is List && startLatLng.length == 2) {
        double dist = Geolocator.distanceBetween(
          currentPosition.value!.latitude,
          currentPosition.value!.longitude,
          startLatLng[0],
          startLatLng[1],
        );
        if (dist < minDistance) {
          minDistance = dist;
          nearest = segment;
        }
      }
    }

    if (nearest != null) {
      final lat = nearest['start_latlng'][0];
      final lng = nearest['start_latlng'][1];
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
      );
      selectSegment(nearest['id']);
    }
  }

  Future<void> _initData() async {
    await determinePosition();
    if (currentPosition.value != null) {
      await fetchNearbySegments();
    }
  }

  Future<void> fetchNearbySegments() async {
    if (currentPosition.value == null) return;
    
    final lat = currentPosition.value!.latitude;
    final lng = currentPosition.value!.longitude;
    
    // Tạo bounds khoảng 5km xung quanh vị trí hiện tại
    const offset = 0.045; // Khoảng 5km
    final southwest = LatLng(lat - offset, lng - offset);
    final northeast = LatLng(lat + offset, lng + offset);
    
    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    await fetchSegments(bounds);
  }

  Future<void> determinePosition() async {
    try {
      isLoadingLocation.value = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      currentPosition.value = position;
    } catch (e) {
      debugPrint("Lỗi khi lấy vị trí: $e");
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    try {
      isLoadingLocation.value = true;

      // Đọc Google Maps API Key từ dotenv
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        Get.snackbar("Lỗi", "Không tìm thấy Google Maps API Key trong cấu hình.");
        return;
      }

      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedQuery&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final double lat = (location['lat'] as num).toDouble();
          final double lng = (location['lng'] as num).toDouble();

          // Cập nhật vị trí hiện tại
          currentPosition.value = Position(
            latitude: lat,
            longitude: lng,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );

          // Di chuyển camera bản đồ đến vị trí tìm được
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15.0),
          );

          // Nạp các cung đường mới xung quanh vị trí này
          await fetchNearbySegments();
        } else {
          Get.snackbar("Thông báo", "Không tìm thấy vị trí yêu cầu.");
        }
      } else {
        Get.snackbar("Lỗi", "Yêu cầu tìm kiếm thất bại.");
      }
    } catch (e) {
      debugPrint("Lỗi tìm kiếm vị trí: $e");
      Get.snackbar("Lỗi", "Đã xảy ra lỗi khi tìm kiếm vị trí.");
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void onMapCreated(GoogleMapController googleMapController) {
    mapController = googleMapController;
    fetchSegmentsInView();
  }

  LatLngBounds? _lastFetchedBounds;

  Future<void> fetchSegmentsInView() async {
    try {
      LatLngBounds bounds = await mapController.getVisibleRegion();
      
      // Nếu vùng hiển thị không thay đổi đáng kể, đừng gọi API
      if (_lastFetchedBounds != null && 
          _isBoundsSimilar(_lastFetchedBounds!, bounds)) {
        return;
      }
      _lastFetchedBounds = bounds;
      await fetchSegments(bounds);
    } catch (e) {
      debugPrint("Lỗi khi lấy vùng bản đồ: $e");
    }
  }

  bool _isBoundsSimilar(LatLngBounds b1, LatLngBounds b2) {
    const double threshold = 0.001; // Ngưỡng thay đổi nhỏ để bỏ qua
    return (b1.southwest.latitude - b2.southwest.latitude).abs() < threshold &&
           (b1.southwest.longitude - b2.southwest.longitude).abs() < threshold &&
           (b1.northeast.latitude - b2.northeast.latitude).abs() < threshold &&
           (b1.northeast.longitude - b2.northeast.longitude).abs() < threshold;
  }

  /// Lấy các đoạn đường dựa trên vùng bản đồ hiện tại
  Future<void> fetchSegments(LatLngBounds bounds) async {
    try {
      isLoading.value = true;
      
      final stravaBounds = [
        bounds.southwest.latitude,
        bounds.southwest.longitude,
        bounds.northeast.latitude,
        bounds.northeast.longitude,
      ];

      final result = await _stravaRepo.exploreSegments(stravaBounds);
      
      if (result.isEmpty) {
        // Mock segments if API returns nothing (e.g. no token)
        _mockSegments();
      } else {
        allSegments.assignAll(result);
      }
      
      applyFilters(shouldFocus: false);
      
    } catch (e) {
      print('Error fetching segments: $e');
      _mockSegments();
    } finally {
      isLoading.value = false;
    }
  }

  void _mockSegments() {
    allSegments.assignAll([
      {
        'id': 101,
        'name': 'Cung đường Hồ Tây (Mock)',
        'distance': 15000.0,
        'avg_grade': 0.1,
        'points': 'u{~_Enwf_Sba@Yf@', // Short mock polyline
        'start_latlng': [21.047, 105.833],
        'end_latlng': [21.048, 105.834],
      },
      {
        'id': 102,
        'name': 'Công viên Thống Nhất (Mock)',
        'distance': 2200.0,
        'avg_grade': 0.0,
        'points': 'u{~_Enwf_Sba@Yf@',
        'start_latlng': [21.016, 105.845],
        'end_latlng': [21.017, 105.846],
      }
    ]);
  }

  int _nextMockSegmentId = 103;

  void loadMoreSegments() {
    final lat = currentPosition.value?.latitude ?? 21.0285;
    final lng = currentPosition.value?.longitude ?? 105.8542;
    final random = Random();

    final List<Map<String, dynamic>> moreMock = [];
    final List<String> segmentNames = [
      'Công viên thành phố',
      'Đường chạy hồ nước',
      'Cung chạy ven sông',
      'Đoạn chạy thử thách dốc',
      'Đường chạy đô thị',
      'Lộ trình ngắm cảnh hoàng hôn',
      'Đường chạy bóng râm',
      'Vòng chạy thể thao',
    ];

    for (int i = 0; i < 5; i++) {
      final id = _nextMockSegmentId++;
      final double latOffset = (random.nextDouble() - 0.5) * 0.03;
      final double lngOffset = (random.nextDouble() - 0.5) * 0.03;
      final double distance = 1000 + random.nextInt(9000).toDouble();
      final double avgGrade = double.parse((random.nextDouble() * 3).toStringAsFixed(1));
      final String name = '${segmentNames[random.nextInt(segmentNames.length)]} $id (Mock)';

      moreMock.add({
        'id': id,
        'name': name,
        'distance': distance,
        'avg_grade': avgGrade,
        'average_grade': avgGrade,
        'points': 'u{~_Enwf_Sba@Yf@',
        'start_latlng': [lat + latOffset, lng + lngOffset],
        'end_latlng': [lat + latOffset + 0.003, lng + lngOffset + 0.003],
      });
    }

    allSegments.addAll(moreMock);
    applyFilters(shouldFocus: false);
  }

  void _updatePolylinesFromSegments() {
    final newPolylines = <Polyline>{};

    for (var segment in segments) {
      final String encodedPolyline = segment['points'] ?? '';
      if (encodedPolyline.isNotEmpty) {
        // Gọi static method trực tiếp, không cần instance
        List<PointLatLng> result = PolylinePoints.decodePolyline(encodedPolyline);
        List<LatLng> points = result
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();

        newPolylines.add(
          Polyline(
            polylineId: PolylineId('segment_${segment['id']}'),
            points: points,
            color: Colors.orange.withOpacity(0.7),
            width: 4,
            consumeTapEvents: true,
            onTap: () {
              selectSegment(segment['id']);
            },
          ),
        );
      }
    }
    polylines.assignAll(newPolylines);
  }

  Future<void> selectSegment(int segmentId) async {
    try {
      isLoadingDetail.value = true;
      // Tìm segment trong list hiện tại (có thông tin cơ bản)
      final basicInfo = segments.firstWhere((s) => s['id'] == segmentId, orElse: () => null);
      selectedSegment.value = basicInfo;

      if (basicInfo != null) {
        final startLatLng = basicInfo['start_latlng'];
        if (startLatLng != null && startLatLng is List && startLatLng.length == 2) {
          try {
            final lat = (startLatLng[0] as num).toDouble();
            final lng = (startLatLng[1] as num).toDouble();
            mapController.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15.0),
            );
          } catch (e) {
            debugPrint("Lỗi di chuyển camera đến cung đường: $e");
          }
        }
      }

      NavigationController.instance.setBottomNavBarVisible(false);

      // Lấy chi tiết và bảng xếp hạng
      final detail = await _stravaRepo.getSegmentDetails(segmentId);
      if (detail != null) {
        selectedSegment.value = detail;
      }

      final leaderboard = await _stravaRepo.getSegmentLeaderboard(segmentId);
      selectedSegmentLeaderboard.assignAll(leaderboard);

    } catch (e) {
      print('Error selecting segment: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }
  
  Future<void> showSegmentDetail(int segmentId) async {
    final detail = await _stravaRepo.getSegmentDetails(segmentId);
    if (detail != null && detail['map'] != null) {
      // Xử lý chi tiết hơn nếu cần
    }
  }
}
