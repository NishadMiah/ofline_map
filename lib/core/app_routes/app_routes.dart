import 'package:ofline_map/view/screens/home/home_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String homeScreen = "/homeScreen";

  static List<GetPage> routes = [
    GetPage(name: homeScreen, page: () => HomeScreen()),
  ];
}
