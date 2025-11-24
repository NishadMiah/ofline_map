import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends GetxController {
  // Map Controller
  final MapController mapController = MapController();

  // Observable variables
  RxList<LatLng> gpxPoints = <LatLng>[].obs;
  RxList<Marker> markers = <Marker>[].obs;
  Rx<LatLng> currentCenter = LatLng(23.8103, 90.4125).obs; // Dhaka default
  RxDouble currentZoom = 13.0.obs;
  RxBool isLoading = false.obs;
  RxString selectedFileName = ''.obs;
  RxDouble totalDistance = 0.0.obs;

  // Location-related
  Rxn<LatLng> currentLocation = Rxn<LatLng>(); // nullable LatLng
  RxBool isTrackingLocation = false.obs; // whether map is following the user
  StreamSubscription<Position>? _positionStreamSub;

  @override
  void onInit() {
    super.onInit();
    _requestPermissions(); // request storage; location requested on demand
  }

  @override
  void onClose() {
    _stopLocationStream();
    try {
      mapController.dispose();
    } catch (_) {}
    super.onClose();
  }

  // -------------------------
  // Permissions
  // -------------------------
  Future<void> _requestPermissions() async {
    // Storage permission for file picking
    try {
      await Permission.storage.request();
    } catch (_) {}
  }

  Future<bool> _ensureLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Location Permission',
          'Location permission is permanently denied. Please enable it from app settings.',
          isError: true,
        );
        return false;
      }

      if (permission == LocationPermission.denied) {
        _showMessage(
          'Location Permission',
          'Location permission denied.',
          isError: true,
        );
        return false;
      }

      return true;
    } catch (e) {
      _showMessage('Permission Error', e.toString(), isError: true);
      return false;
    }
  }

  // -------------------------
  // Location: start/stop stream, single center
  // -------------------------
  Future<void> startLocationTracking({bool follow = true}) async {
    final ok = await _ensureLocationPermission();
    if (!ok) return;

    // If stream already running just toggle follow flag
    if (_positionStreamSub != null) {
      isTrackingLocation.value = follow;
      return;
    }

    // Location settings for the stream
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // meters
    );

    try {
      _positionStreamSub = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position pos) {
        final latLng = LatLng(pos.latitude, pos.longitude);
        currentLocation.value = latLng;

        if (isTrackingLocation.value) {
          currentCenter.value = latLng;
          // Keep the same zoom but move to the new center
          try {
            mapController.move(latLng, currentZoom.value);
          } catch (_) {
            // ignore errors if controller not ready
          }
        }
      }, onError: (err) {
        _showMessage('Location Error', err.toString(), isError: true);
      });

      isTrackingLocation.value = follow;
    } catch (e) {
      _showMessage('Location Error', e.toString(), isError: true);
    }
  }

  void stopLocationTracking() {
    isTrackingLocation.value = false;
    _stopLocationStream();
  }

  void _stopLocationStream() {
    if (_positionStreamSub != null) {
      _positionStreamSub!.cancel();
      _positionStreamSub = null;
    }
  }

  Future<void> centerOnCurrentLocationOnce() async {
    final ok = await _ensureLocationPermission();
    if (!ok) return;

    try {
      isLoading.value = true;
      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      currentLocation.value = latLng;
      currentCenter.value = latLng;
      try {
        mapController.move(latLng, currentZoom.value);
      } catch (_) {}
    } catch (e) {
      _showMessage('Location Error', 'Could not get current location: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------
  // GPX file picking and parsing
  // -------------------------
  Future<void> pickGpxFile() async {
    try {
      isLoading.value = true;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;

        // Check if file is GPX
        if (!fileName.toLowerCase().endsWith('.gpx')) {
          _showMessage(
            'Invalid File',
            'Please select a GPX file',
            isError: true,
          );
          return;
        }

        File file = File(filePath);
        selectedFileName.value = fileName;

        await _parseGpxFile(file);

        if (gpxPoints.isNotEmpty) {
          _centerMapOnRoute();
          _calculateDistance();
          _showMessage(
            'Success',
            'GPX file loaded successfully!',
            isError: false,
          );
        } else {
          _showMessage(
            'No Data',
            'No track points found in GPX file',
            isError: true,
          );
        }
      }
    } catch (e) {
      _showMessage(
        'Error',
        'Failed to load GPX file: ${e.toString()}',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Show message using SnackBar (not GetX snackbar)
  void _showMessage(String title, String message, {required bool isError}) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(message),
            ],
          ),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  // Parse GPX file
  Future<void> _parseGpxFile(File file) async {
    try {
      String xmlString = await file.readAsString();
      final document = XmlDocument.parse(xmlString);

      gpxPoints.clear();
      markers.clear();

      // Parse track points (trkpt)
      final trackPoints = document.findAllElements('trkpt');
      for (var point in trackPoints) {
        double? lat = double.tryParse(point.getAttribute('lat') ?? '');
        double? lon = double.tryParse(point.getAttribute('lon') ?? '');

        if (lat != null && lon != null) {
          gpxPoints.add(LatLng(lat, lon));
        }
      }

      // Parse route points (rtept)
      final routePoints = document.findAllElements('rtept');
      for (var point in routePoints) {
        double? lat = double.tryParse(point.getAttribute('lat') ?? '');
        double? lon = double.tryParse(point.getAttribute('lon') ?? '');

        if (lat != null && lon != null) {
          gpxPoints.add(LatLng(lat, lon));
        }
      }

      // Parse waypoints (wpt)
      final waypoints = document.findAllElements('wpt');
      for (var point in waypoints) {
        double? lat = double.tryParse(point.getAttribute('lat') ?? '');
        double? lon = double.tryParse(point.getAttribute('lon') ?? '');
        String name = point.findElements('name').isNotEmpty
            ? point.findElements('name').first.text
            : 'Waypoint';

        if (lat != null && lon != null) {
          markers.add(
            Marker(
              point: LatLng(lat, lon),
              width: 80,
              height: 80,
              child: Column(
                children: [
                  Icon(Icons.location_on, color: Colors.red, size: 40),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      throw Exception('Error parsing GPX file: $e');
    }
  }

  // Center map on the route (manual bounding-box -> centroid)
  void _centerMapOnRoute() {
    if (gpxPoints.isEmpty) return;

    double minLat = gpxPoints.first.latitude;
    double maxLat = gpxPoints.first.latitude;
    double minLon = gpxPoints.first.longitude;
    double maxLon = gpxPoints.first.longitude;

    for (var point in gpxPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
    }

    LatLng center = LatLng((minLat + maxLat) / 2, (minLon + maxLon) / 2);
    currentCenter.value = center;

    // Try moving to center; keep current zoom
    try {
      mapController.move(center, currentZoom.value);
    } catch (_) {
      // MapController might not be ready; ignore
    }
  }

  // Calculate total distance
  void _calculateDistance() {
    if (gpxPoints.length < 2) {
      totalDistance.value = 0.0;
      return;
    }

    const Distance distance = Distance();
    double total = 0.0;

    for (int i = 0; i < gpxPoints.length - 1; i++) {
      total += distance.as(
        LengthUnit.Kilometer,
        gpxPoints[i],
        gpxPoints[i + 1],
      );
    }

    totalDistance.value = total;
  }

  // Clear route
  void clearRoute() {
    gpxPoints.clear();
    markers.clear();
    selectedFileName.value = '';
    totalDistance.value = 0.0;
    currentCenter.value = LatLng(23.8103, 90.4125);
    try {
      mapController.move(currentCenter.value, 13.0);
    } catch (_) {}
  }

  // Zoom controls
  void zoomIn() {
    currentZoom.value = (currentZoom.value + 1).clamp(1, 18);
    try {
      mapController.move(currentCenter.value, currentZoom.value);
    } catch (_) {}
  }

  void zoomOut() {
    currentZoom.value = (currentZoom.value - 1).clamp(1, 18);
    try {
      mapController.move(currentCenter.value, currentZoom.value);
    } catch (_) {}
  }
}
