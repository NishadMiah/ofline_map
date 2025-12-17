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
            () => controller.loadedRoutes.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: controller.clearRoutes,
                    tooltip: 'Clear Routes',
                  )
                : SizedBox.shrink(),
          ),
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.pdfToText);
            },
            icon: Icon(Icons.telegram),
          ),
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.planJourney);
            },
            icon: Icon(Icons.map), // Journey Plan icon
            tooltip: "Plan Journey",
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
                // Tile Layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.offline_map',
                ),

                // GPX Route Polylines
                if (controller.loadedRoutes.isNotEmpty)
                  PolylineLayer(
                    polylines: controller.loadedRoutes.map((route) {
                      return Polyline(
                        points: route.points,
                        strokeWidth: 4.0,
                        color: route.color,
                        borderColor: Colors.white,
                        borderStrokeWidth: 1.0,
                      );
                    }).toList(),
                  ),

                // Markers Layer (waypoints from all routes)
                if (controller.loadedRoutes.any((r) => r.markers.isNotEmpty))
                  MarkerLayer(
                    markers: controller.loadedRoutes
                        .expand((route) => route.markers)
                        .toList(),
                  ),

                // Start & End Markers for each route
                if (controller.loadedRoutes.isNotEmpty)
                  MarkerLayer(
                    markers: controller.loadedRoutes.expand((route) {
                      if (route.points.isEmpty) return <Marker>[];
                      return [
                        Marker(
                          point: route.points.first,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.play_circle,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                        Marker(
                          point: route.points.last,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.flag, color: Colors.red, size: 30),
                        ),
                      ];
                    }).toList(),
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

          // Info Card (Scrollable list of loaded files)
          Positioned(
            top: 16.h,
            left: 16.w,
            right: 16.w,
            child: Obx(
              () => controller.loadedRoutes.isNotEmpty
                  ? Container(
                      constraints: BoxConstraints(maxHeight: 200.h),
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Loaded Routes (${controller.loadedRoutes.length})',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Total: ${controller.totalAllDistance.toStringAsFixed(2)} km',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.loadedRoutes.length,
                              itemBuilder: (context, index) {
                                final route = controller.loadedRoutes[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12.w,
                                        height: 12.w,
                                        decoration: BoxDecoration(
                                          color: route.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          route.fileName,
                                          style: TextStyle(fontSize: 12.sp),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${route.distance.toStringAsFixed(2)} km',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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
              onPressed: controller.pickGpxFiles,
              icon: Icon(Icons.file_upload, size: 24.sp),
              label: Text(
                'Load GPX Files',
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
}
