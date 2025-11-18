import 'package:flutter/material.dart';
import 'package:ofline_map/utils/app_size/app_size.dart';
import 'package:ofline_map/view/components/custom_text/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'NFC App',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Padding(
        padding: AppSize.padding,
        child: Column(children: [
         
          ],
        ),
      ),
    );
  }
}
