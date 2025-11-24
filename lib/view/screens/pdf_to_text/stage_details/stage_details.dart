import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ofline_map/view/screens/pdf_to_text/controller/pdf_to_text_controller.dart';

class StageDetails extends StatelessWidget {
  const StageDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdfToTextController>();
    final Map<String, dynamic> args = Get.arguments;

    // Trigger data load
    // Using a microtask to avoid calling setState during build if the controller updates immediately
    Future.microtask(() => controller.loadStageDetail(args['page']));

    // Custom background color based on the image (Light Blue-Grey)
    final backgroundColor = Color(0xFFB8C9D3);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "Stage Details",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.selectedStageDetails;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header: Route Name ---
              Text(
                args['route'] ?? "Route Name",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),

              // --- Stats Grid ---
              _buildStatRow("Distance", data['distance']),
              _buildStatRow("Time", data['time']),
              _buildStatRow("Accumulated ascent", data['ascent']),
              _buildStatRow("Accumulated descent", data['descent']),

              SizedBox(height: 16.h),

              // --- Elevation Profile ---
              Text(
                "Elevation Profile:",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 40.sp,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Elevation Chart Placeholder",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // --- Walking Surface ---
              _buildSectionTitle("Walking Surface:"),
              _buildBulletPoints(data['walking_surface']),

              SizedBox(height: 16.h),

              // --- Challenges ---
              _buildSectionTitle("Challenges:"),
              _buildBulletPoints(data['challenges']),

              SizedBox(height: 16.h),

              // --- Highlights ---
              _buildSectionTitle("Highlights:"),
              _buildBulletPoints(data['highlights']),

              SizedBox(height: 30.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
          Text(
            value ?? "--",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBulletPoints(String? content) {
    if (content == null || content == "N/A") {
      return Text(
        "- N/A",
        style: TextStyle(fontSize: 14.sp, color: Colors.black87),
      );
    }

    // Split by newlines and create a list of widgets
    List<String> lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "- ",
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              ),
              Expanded(
                child: Text(
                  line.trim().startsWith('-')
                      ? line.trim().substring(1).trim()
                      : line.trim(),
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
