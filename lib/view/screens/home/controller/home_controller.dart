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

class GpxRoute {
  final String id;
  final String fileName;
  final List<LatLng> points;
  final List<Marker> markers;
  final double distance;
  final Color color;

  GpxRoute({
    required this.id,
    required this.fileName,
    required this.points,
    required this.markers,
    required this.distance,
    required this.color,
  });
}

class HomeController extends GetxController {
  // Map Controller
  final MapController mapController = MapController();

  // Observable variables
  RxList<GpxRoute> loadedRoutes = <GpxRoute>[].obs;
  Rx<LatLng> currentCenter = LatLng(23.8103, 90.4125).obs; // Dhaka default
  RxDouble currentZoom = 13.0.obs;
  RxBool isLoading = false.obs;

  // Computed property for total distance across all routes
  double get totalAllDistance =>
      loadedRoutes.fold(0.0, (sum, route) => sum + route.distance);

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
    LocationSettings locationSettings;

    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 2),
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      );
    }

    try {
      _positionStreamSub =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position pos) {
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
            },
            onError: (err) {
              _showMessage('Location Error', err.toString(), isError: true);
            },
          );

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

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage(
        'Location Disabled',
        'Please enable location services.',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 1. Try to get last known position first (fastest)
      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final latLng = LatLng(lastKnown.latitude, lastKnown.longitude);
        currentLocation.value = latLng;
        currentCenter.value = latLng;
        try {
          mapController.move(latLng, currentZoom.value);
        } catch (_) {}
      }

      // 2. Try to get fresh position
      LocationSettings locationSettings;
      if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.best,
          forceLocationManager: true,
          timeLimit: const Duration(seconds: 10),
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        );
      }

      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      final latLng = LatLng(pos.latitude, pos.longitude);
      currentLocation.value = latLng;
      currentCenter.value = latLng;
      try {
        mapController.move(latLng, currentZoom.value);
      } catch (_) {}
    } catch (e) {
      if (currentLocation.value != null) {
        _showMessage(
          'GPS Signal Weak',
          'Using last known location. Move outdoors for better signal.',
          isError: false,
        );
      } else {
        _showMessage(
          'Location Error',
          'Could not get current location. Ensure you are outdoors.',
          isError: true,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------
  // GPX file picking and parsing
  // -------------------------
  Future<void> pickGpxFiles() async {
    try {
      isLoading.value = true;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        int successCount = 0;

        for (var fileInfo in result.files) {
          if (fileInfo.path == null) continue;

          String filePath = fileInfo.path!;
          String fileName = fileInfo.name;

          // Check if file is GPX
          if (!fileName.toLowerCase().endsWith('.gpx')) {
            continue; // Skip non-gpx files
          }

          File file = File(filePath);
          try {
            final route = await _parseGpxFile(file, fileName);
            if (route != null) {
              loadedRoutes.add(route);
              successCount++;
            }
          } catch (e) {
            print("Error parsing $fileName: $e");
          }
        }

        if (successCount > 0) {
          _centerMapOnAllRoutes();
          _showMessage(
            'Success',
            '$successCount GPX file(s) loaded successfully!',
            isError: false,
          );
        } else {
          _showMessage('No Data', 'No valid GPX tracks found.', isError: true);
        }
      }
    } catch (e) {
      _showMessage(
        'Error',
        'Failed to load GPX files: ${e.toString()}',
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(message),
            ],
          ),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // Parse GPX file and return GpxRoute
  Future<GpxRoute?> _parseGpxFile(File file, String fileName) async {
    try {
      String xmlString = await file.readAsString();
      final document = XmlDocument.parse(xmlString);

      List<LatLng> points = [];
      List<Marker> markers = [];

      // Parse track points (trkpt)
      final trackPoints = document.findAllElements('trkpt');
      for (var point in trackPoints) {
        double? lat = double.tryParse(point.getAttribute('lat') ?? '');
        double? lon = double.tryParse(point.getAttribute('lon') ?? '');

        if (lat != null && lon != null) {
          points.add(LatLng(lat, lon));
        }
      }

      // Parse route points (rtept)
      final routePoints = document.findAllElements('rtept');
      for (var point in routePoints) {
        double? lat = double.tryParse(point.getAttribute('lat') ?? '');
        double? lon = double.tryParse(point.getAttribute('lon') ?? '');

        if (lat != null && lon != null) {
          points.add(LatLng(lat, lon));
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

      if (points.isEmpty) return null;

      // Calculate distance for this route
      double dist = _calculateDistance(points);

      // Assign a random color
      final color =
          Colors.primaries[DateTime.now().microsecondsSinceEpoch %
              Colors.primaries.length];

      return GpxRoute(
        id: DateTime.now().toIso8601String(), // simple unique id
        fileName: fileName,
        points: points,
        markers: markers,
        distance: dist,
        color: color,
      );
    } catch (e) {
      print('Error parsing GPX file $fileName: $e');
      return null;
    }
  }

  // Center map on all routes
  void _centerMapOnAllRoutes() {
    if (loadedRoutes.isEmpty) return;

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLon = 180.0;
    double maxLon = -180.0;

    bool hasPoints = false;

    for (var route in loadedRoutes) {
      for (var point in route.points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLon) minLon = point.longitude;
        if (point.longitude > maxLon) maxLon = point.longitude;
        hasPoints = true;
      }
    }

    if (!hasPoints) return;

    LatLng center = LatLng((minLat + maxLat) / 2, (minLon + maxLon) / 2);
    currentCenter.value = center;

    // Try moving to center; keep current zoom
    try {
      mapController.move(center, currentZoom.value);
    } catch (_) {
      // MapController might not be ready; ignore
    }
  }

  // Calculate distance for a list of points
  double _calculateDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    const Distance distance = Distance();
    double total = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      total += distance.as(LengthUnit.Kilometer, points[i], points[i + 1]);
    }
    return total;
  }

  // Clear all routes
  void clearRoutes() {
    loadedRoutes.clear();
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
