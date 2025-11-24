import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ofline_map/core/app_routes/app_routes.dart';
import 'package:ofline_map/view/screens/home/controller/home_controller.dart';
import 'package:ofline_map/utils/app_colors/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Offline Map - GPX Viewer',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundClr,
        elevation: 2,
        actions: [
          Obx(
            () => controller.gpxPoints.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: controller.clearRoute,
                    tooltip: 'Clear Route',
                  )
                : SizedBox.shrink(),
          ),
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.pdfToText);
            },
            icon: Icon(Icons.telegram),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Widget
          Obx(
            () => FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.currentCenter.value,
                initialZoom: controller.currentZoom.value,
                minZoom: 1,
                maxZoom: 18,
              ),

              children: [
                // Tile Layer - Online by default; you can replace with offline file-based tiles or MBTiles provider
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.offline_map',
                  // For offline: use local tile provider or MBTiles plugin integration
                ),

                // GPX Route Polyline
                if (controller.gpxPoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: controller.gpxPoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                        borderColor: Colors.white,
                        borderStrokeWidth: 2.0,
                      ),
                    ],
                  ),

                // Markers Layer (waypoints)
                if (controller.markers.isNotEmpty)
                  MarkerLayer(markers: controller.markers),

                // Start & End Markers (use `child:`)
                if (controller.gpxPoints.length > 1)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: controller.gpxPoints.first,
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.play_circle,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),
                      Marker(
                        point: controller.gpxPoints.last,
                        width: 50,
                        height: 50,
                        child: Icon(Icons.flag, color: Colors.red, size: 40),
                      ),
                    ],
                  ),

                // Current Location Marker (if available)
                Obx(() {
                  final loc = controller.currentLocation.value;
                  if (loc == null) return SizedBox.shrink();
                  return MarkerLayer(
                    markers: [
                      Marker(
                        point: loc,
                        width: 60,
                        height: 60,
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Loading Indicator
          Obx(
            () => controller.isLoading.value
                ? Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : SizedBox.shrink(),
          ),

          // Info Card
          Positioned(
            top: 16.h,
            left: 16.w,
            right: 16.w,
            child: Obx(
              () => controller.selectedFileName.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.route,
                                color: Colors.blue,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  controller.selectedFileName.value,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoItem(
                                icon: Icons.straighten,
                                label: 'Distance',
                                value:
                                    '${controller.totalDistance.value.toStringAsFixed(2)} km',
                              ),
                              _buildInfoItem(
                                icon: Icons.location_on,
                                label: 'Points',
                                value: '${controller.gpxPoints.length}',
                              ),
                              _buildInfoItem(
                                icon: Icons.flag,
                                label: 'Markers',
                                value: '${controller.markers.length}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ),

          // Zoom Controls
          Positioned(
            right: 16.w,
            bottom: 160.h,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_in',
                  backgroundColor: Colors.white,
                  onPressed: controller.zoomIn,
                  child: Icon(Icons.add, color: Colors.black),
                ),
                SizedBox(height: 8.h),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_out',
                  backgroundColor: Colors.white,
                  onPressed: controller.zoomOut,
                  child: Icon(Icons.remove, color: Colors.black),
                ),
              ],
            ),
          ),

          // Location Controls (center once + follow toggle)
          Positioned(
            right: 16.w,
            bottom: 24.h,
            child: Column(
              children: [
                // Center once
                FloatingActionButton(
                  heroTag: 'loc_once',
                  backgroundColor: Colors.white,
                  onPressed: () => controller.centerOnCurrentLocationOnce(),
                  child: Icon(Icons.my_location, color: Colors.black),
                ),
                SizedBox(height: 8.h),
                // Toggle follow mode
                Obx(
                  () => FloatingActionButton(
                    heroTag: 'loc_toggle',
                    backgroundColor: controller.isTrackingLocation.value
                        ? Colors.blueAccent
                        : Colors.white,
                    onPressed: () {
                      if (controller.isTrackingLocation.value) {
                        controller.isTrackingLocation.value = false;
                        controller.stopLocationTracking();
                      } else {
                        controller.startLocationTracking(follow: true);
                      }
                    },
                    child: Icon(
                      controller.isTrackingLocation.value
                          ? Icons.gps_fixed
                          : Icons.gps_not_fixed,
                      color: controller.isTrackingLocation.value
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),

          // Load GPX Button
          Positioned(
            bottom: 24.h,
            left: 16.w,
            right: 16.w + 80.w, // leave space on right for location buttons
            child: ElevatedButton.icon(
              onPressed: controller.pickGpxFile,
              icon: Icon(Icons.file_upload, size: 24.sp),
              label: Text(
                'Load GPX File',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[600]),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
