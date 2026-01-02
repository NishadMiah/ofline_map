import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ofline_map/data/models/route_model.dart';

class PlanJourneyController extends GetxController {
  RxList<CaminoRoute> allRoutes = <CaminoRoute>[].obs;
  RxBool isLoading = false.obs;

  // Selections
  RxString selectedRouteName = ''.obs;
  RxString selectedDailyDistance = ''.obs;
  RxString selectedStartingPoint = ''.obs;
  RxBool spiritualVariant = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRoutes();
  }

  Future<void> loadRoutes() async {
    try {
      isLoading.value = true;
      final String response = await rootBundle.loadString(
        'assets/pdf/json/route_new.json',
      );
      final data = json.decode(response);
      final routeModel = RouteModel.fromJson(data);
      if (routeModel.caminoRoutes != null) {
        allRoutes.value = routeModel.caminoRoutes!;

        // Default selections if available
        if (allRoutes.isNotEmpty) {
          // For now, initially select the first one or leave empty to prompt user
          // selectedRouteName.value = allRoutes.first.routeName ?? '';
        }
      }
    } catch (e) {
      print("Error loading routes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Getters for dropdown options
  // Note: Since logic can be complex with many permutations, for this JSON
  // we will map available options based on unique values found in data
  // or hardcoded if UI requires specific static options that filter data.

  // Based on the UI image, "Select Route" has: Central Route, Coastal Route, etc.
  // "Average Daily Distance" has ranges.
  // "Starting Point" has specific options.

  // For the purpose of this task using the provided JSON (which only has 1 route),
  // we will populate lists based on what we see in JSON + dummies to match UI look if needed,
  // OR strictly from JSON.
  // The JSON provided has: "Litoral+ Central Route", "First Range", "Option-01..."

  List<String> get availableRouteNames {
    // Return unique route names from loaded data
    // Plus maybe hardcode others to match UI if they don't exist in JSON but need to be shown as options
    final names = allRoutes
        .map((e) => e.routeName)
        .whereType<String>()
        .toSet()
        .toList();
    // If JSON only has 1, but we want to simulate UI:
    if (!names.contains("Central Route")) names.add("Central Route");
    if (!names.contains("Coastal Route")) names.add("Coastal Route");
    if (!names.contains("Litoral Way")) names.add("litoral");
    if (!names.contains("Coastal+ Central Route"))
      names.add("Coastal+ Central Route");
    return names;
  }

  List<String> get availableDailyDistances {
    // From JSON: "distance_range": "First Range"
    final ranges = allRoutes
        .map((e) => e.filterOptions?.distanceRange)
        .whereType<String>()
        .toSet()
        .toList();
    // Add UI dummies
    if (!ranges.contains("10-16 km/ 6.2-10 mi"))
      ranges.add("10-16 km/ 6.2-10 mi");
    if (!ranges.contains("16-20 km/ 10-12 mi"))
      ranges.add("16-20 km/ 10-12 mi");
    if (!ranges.contains("20-25 km/ 12.4-15.5 mi"))
      ranges.add("20-25 km/ 12.4-15.5 mi");
    if (!ranges.contains("25+ km/ 15.5+ mi")) ranges.add("25+ km/ 15.5+ mi");

    return ranges;
  }

  List<String> get availableStartingPoints {
    // From JSON: "distance_label": "Option-01 (230 km, 12 days)"
    final points = allRoutes
        .map((e) => e.filterOptions?.distanceLabel)
        .whereType<String>()
        .toSet()
        .toList();
    if (!points.contains("Option-01 (230 km, 12 days)"))
      points.add("Option-01 (230 km, 12 days)");
    if (!points.contains("Option-02 (120km, 09 days)"))
      points.add("Option-02 (120km, 09 days)");
    if (!points.contains("Option-03 (107 km, 07 days)"))
      points.add("Option-03 (107 km, 07 days)");
    return points;
  }

  // Find the matching route based on selections
  CaminoRoute? get matchingRoute {
    // Simple logic: returns the route that matches the selected name.
    // In a real app, this would match multiple criteria.
    // If selectedRouteName is empty, return null.
    try {
      return allRoutes.firstWhere(
        (element) => element.routeName == selectedRouteName.value,
      );
    } catch (e) {
      return null;
    }
  }
}
