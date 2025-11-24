import 'package:ofline_map/view/screens/home/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:ofline_map/view/screens/pdf_to_text/controller/pdf_to_text_controller.dart';

class DependencyInjection extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => PdfToTextController(), fenix: true);
  }
}
