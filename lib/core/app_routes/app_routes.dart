import 'package:ofline_map/view/screens/home/home_screen.dart';
import 'package:get/get.dart';
import 'package:ofline_map/view/screens/pdf_to_text/pdf_to_text.dart';
import 'package:ofline_map/view/screens/pdf_to_text/stage_details/stage_details.dart';

class AppRoutes {
  static const String homeScreen = "/homeScreen";
  static const String pdfToText = "/pdfToText";
  static const String stageDetails = "/stageDetails";

  static List<GetPage> routes = [
    GetPage(name: homeScreen, page: () => HomeScreen()),
    GetPage(name: pdfToText, page: () => PdfToText()),
    GetPage(name: stageDetails, page: () => StageDetails()),
  ];
}
