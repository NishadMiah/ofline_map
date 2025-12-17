import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ofline_map/core/app_routes/app_routes.dart';
import 'package:ofline_map/view/screens/plan_journey/controller/plan_journey_controller.dart';

class PlanDetailsScreen extends StatelessWidget {
  PlanDetailsScreen({super.key});

  final PlanJourneyController controller = Get.find<PlanJourneyController>();

  @override
  Widget build(BuildContext context) {
    // Current route must exist if we navigated here
    final route = controller.matchingRoute!;
    final stages = route.stages ?? [];

    // Header Info (Mock or from Route data)
    final headerInfo =
        "Central Route - 20km per day Porto to\nSantiago de Compostela";
    final allStagesText = "All Stages:";

    return Scaffold(
      backgroundColor: Color(0xFFBCCCD7), // Light Blueish Grey from image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Plan Details',
          style: TextStyle(color: Colors.black, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerInfo,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  allStagesText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: stages.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final stage = stages[index];
                final title = "Day ${stage.stageNumber} - ${stage.stageName}";
                final dist = "${stage.distanceKm} km";

                return GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.journeyStageDetails,
                      arguments: stage,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.w.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          dist,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
