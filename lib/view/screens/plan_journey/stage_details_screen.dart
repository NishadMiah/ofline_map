import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ofline_map/data/models/route_model.dart';

class StageDetailsScreen extends StatelessWidget {
  const StageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get stage from arguments
    final Stage stage = Get.arguments as Stage;
    final d = stage.details;

    return Scaffold(
      backgroundColor: Color(0xFFBCCCD7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Stage Details',
          style: TextStyle(color: Colors.black, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Day ${stage.stageNumber} - ${stage.stageName}",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),

            // Stats Table
            _buildStatRow('Distance:', "${stage.distanceKm} km"),
            _buildStatRow('Time:', d?.totalTime ?? 'N/A'),
            _buildStatRow('Accumulated ascent:', d?.accumulatedAscent ?? 'N/A'),
            _buildStatRow(
              'Accumulated descent:',
              d?.accumulatedDescent ?? 'N/A',
            ),

            SizedBox(height: 16.h),
            Text(
              "Elevation Profile:",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            // Placeholder for Chart
            Container(
              height: 150.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  'Chart Placeholder',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            SizedBox(height: 16.h),
            _buildSectionTitle('Walking Surface:'),
            if (d?.walkingSurface != null)
              ...d!.walkingSurface!.map((s) => _buildBulletPoint(s)),

            SizedBox(height: 16.h),
            _buildSectionTitle('Challenges:'),
            if (d?.challenges != null)
              ...d!.challenges!.map((s) => _buildBulletPoint(s)),

            SizedBox(height: 16.h),
            _buildSectionTitle('Highlights:'),
            if (d?.highlights != null)
              ...d!.highlights!.map((s) => _buildBulletPoint(s)),

            SizedBox(height: 32.h),

            // Buttons
            _buildActionButton(
              'Accommodation',
              Color(0xFFF3DFA2),
              Colors.black,
            ),
            SizedBox(height: 12.h),
            _buildActionButton('Navigate', Colors.black, Colors.white),
            SizedBox(height: 12.h),
            _buildActionButton(
              'Route Description',
              Colors.transparent,
              Colors.black,
              isOutlined: true,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp)),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
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
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("- ", style: TextStyle(fontSize: 14.sp)),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    Color bg,
    Color text, {
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: text,
          side: isOutlined ? BorderSide(color: Colors.black) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
