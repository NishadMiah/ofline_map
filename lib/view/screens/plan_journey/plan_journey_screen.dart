import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ofline_map/core/app_routes/app_routes.dart';

import 'package:ofline_map/view/screens/plan_journey/controller/plan_journey_controller.dart';

class PlanJourneyScreen extends StatelessWidget {
  PlanJourneyScreen({super.key});

  final PlanJourneyController controller = Get.put(PlanJourneyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A52), // Dark blue bg
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A52),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Plan My Journey',
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildDropdownSection(
              title: 'Select Route',
              icon: Icons.map_outlined,
              child: Obx(
                () => Column(
                  children: controller.availableRouteNames.map((name) {
                    return _buildRadioOption(
                      label: name,
                      groupValue: controller.selectedRouteName.value,
                      value: name,
                      onChanged: (val) {
                        controller.selectedRouteName.value = val.toString();
                        debugPrint("Selected Route Name: ${val.toString()}");
                        if (controller.matchingRoute != null) {
                          final r = controller.matchingRoute!;
                          if (r.filterOptions?.distanceRange != null) {
                            controller.selectedDailyDistance.value =
                                r.filterOptions!.distanceRange!;
                          }

                          if (r.filterOptions?.distanceLabel != null) {
                            controller.selectedStartingPoint.value =
                                r.filterOptions!.distanceLabel!;
                          }
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            _buildDropdownSection(
              title: 'Average Daily Distance',
              icon: Icons.directions_walk,
              child: Obx(
                () => Column(
                  children: controller.availableDailyDistances.map((dist) {
                    return _buildRadioOption(
                      label: dist,
                      groupValue: controller.selectedDailyDistance.value,
                      value: dist,
                      onChanged: (val) =>
                          controller.selectedDailyDistance.value = val
                              .toString(),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            _buildDropdownSection(
              title: 'Add Spiritual Variant',
              icon: Icons.church_outlined,
              child: Obx(
                () => Column(
                  children: [
                    _buildRadioOption(
                      label: 'Yes',
                      groupValue: controller.spiritualVariant.value
                          ? 'Yes'
                          : 'No',
                      value: 'Yes',
                      onChanged: (_) =>
                          controller.spiritualVariant.value = true,
                    ),
                    _buildRadioOption(
                      label: 'No',
                      groupValue: controller.spiritualVariant.value
                          ? 'Yes'
                          : 'No',
                      value: 'No',
                      onChanged: (_) =>
                          controller.spiritualVariant.value = false,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            _buildDropdownSection(
              title: 'Starting Point',
              icon: Icons.flag_outlined,
              child: Obx(
                () => Column(
                  children: controller.availableStartingPoints.map((point) {
                    return _buildRadioOption(
                      label: point,
                      groupValue: controller.selectedStartingPoint.value,
                      value: point,
                      onChanged: (val) =>
                          controller.selectedStartingPoint.value = val
                              .toString(),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // KM / Mile Toggle (Mock)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text('KM'),
                    trailing: Radio(
                      value: true,
                      groupValue: true,
                      onChanged: (_) {},
                    ),
                    dense: true,
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Text('Mile'),
                    trailing: Radio(
                      value: false,
                      groupValue: true,
                      onChanged: (_) {},
                    ),
                    dense: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (controller.matchingRoute != null) {
                    Get.toNamed(AppRoutes.planDetails);
                  } else {
                    // Get.snackbar(
                    //   "Select Route",
                    //   "Please select a valid route first (e.g., Litoral+ Central Route)",
                    //   backgroundColor: Colors.white,
                    // );
                  }
                },
                icon: Icon(Icons.hiking, color: Colors.black),
                label: Text(
                  'Plan My Journey',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF3DFA2), // Beige color
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: Icon(icon, color: Colors.black54),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
          backgroundColor: Color(0xFFF3DFA2), // Beige when expanded
          collapsedBackgroundColor: Color(0xFFF3DFA2),
          textColor: Colors.black,
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          childrenPadding: EdgeInsets.zero,
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String label,
    required String groupValue,
    required String value,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: RadioListTile<String>(
        title: Text(label, style: TextStyle(fontSize: 14.sp)),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: const Color(0xFF1E3A52),
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      ),
    );
  }
}
