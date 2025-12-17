import 'package:ofline_map/view/screens/home/home_screen.dart';
import 'package:get/get.dart';
import 'package:ofline_map/view/screens/pdf_to_text/pdf_to_text.dart';
import 'package:ofline_map/view/screens/pdf_to_text/stage_details/stage_details.dart';

import 'package:ofline_map/view/screens/plan_journey/plan_journey_screen.dart';
import 'package:ofline_map/view/screens/plan_journey/plan_details_screen.dart';
import 'package:ofline_map/view/screens/plan_journey/stage_details_screen.dart'
    as journey;

class AppRoutes {
  static const String homeScreen = "/homeScreen";
  static const String pdfToText = "/pdfToText";
  static const String stageDetails = "/stageDetails";
  static const String planJourney = "/planJourney";
  static const String planDetails = "/planDetails";
  static const String journeyStageDetails = "/journeyStageDetails";

  static List<GetPage> routes = [
    GetPage(name: homeScreen, page: () => HomeScreen()),
    GetPage(name: pdfToText, page: () => PdfToText()),
    GetPage(name: stageDetails, page: () => StageDetails()),
    GetPage(name: planJourney, page: () => PlanJourneyScreen()),
    GetPage(name: planDetails, page: () => PlanDetailsScreen()),
    GetPage(
      name: journeyStageDetails,
      page: () => journey.StageDetailsScreen(),
    ),
  ];
}
