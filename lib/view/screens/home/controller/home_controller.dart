import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';
import 'package:permission_handler/permission_handler.dart';

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
  
  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
  }

  // Request storage permissions
  Future<void> _requestPermissions() async {
    await Permission.storage.request();
  }

  // Pick and parse GPX file
  Future<void> pickGpxFile() async {
    try {
      isLoading.value = true;
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gpx'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        selectedFileName.value = result.files.single.name;
        
        await _parseGpxFile(file);
        
        if (gpxPoints.isNotEmpty) {
          _centerMapOnRoute();
          _calculateDistance();
          Get.snackbar(
            'Success',
            'GPX file loaded successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load GPX file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
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
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.white,
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

  // Center map on the route
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
    
    mapController.move(center, 13.0);
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
    mapController.move(currentCenter.value, 13.0);
  }

  // Zoom controls
  void zoomIn() {
    currentZoom.value = (currentZoom.value + 1).clamp(1, 18);
    mapController.move(mapController.camera.center, currentZoom.value);
  }

  void zoomOut() {
    currentZoom.value = (currentZoom.value - 1).clamp(1, 18);
    mapController.move(mapController.camera.center, currentZoom.value);
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }
}