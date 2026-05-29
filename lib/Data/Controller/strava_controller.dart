import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import '../Repository/strava_repository.dart';

class StravaController extends GetxController {
  static StravaController get instance => Get.find();

  final _stravaRepo = StravaRepository.instance;
  
  // Bản đồ & Vị trí
  late GoogleMapController mapController;
  var currentPosition = Rxn<Position>();
  var isLoadingLocation = true.obs;
  
  var segments = <dynamic>[].obs;
  var isLoading = false.obs;
  var polylines = <Polyline>{}.obs;
  
  var selectedSegment = Rxn<dynamic>();
  var selectedSegmentLeaderboard = <dynamic>[].obs;
  var isLoadingDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
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

      Position position = await Geolocator.getCurrentPosition();
      currentPosition.value = position;
    } catch (e) {
      debugPrint("Lỗi khi lấy vị trí: $e");
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void onMapCreated(GoogleMapController googleMapController) {
    mapController = googleMapController;
    fetchSegmentsInView();
  }

  Future<void> fetchSegmentsInView() async {
    try {
      LatLngBounds bounds = await mapController.getVisibleRegion();
      await fetchSegments(bounds);
    } catch (e) {
      debugPrint("Lỗi khi lấy vùng bản đồ: $e");
    }
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
      segments.assignAll(result);
      
      _updatePolylinesFromSegments();
      
    } catch (e) {
      print('Error fetching segments: $e');
    } finally {
      isLoading.value = false;
    }
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
