class RouteModel {
  final List<CaminoRoute>? caminoRoutes;

  RouteModel({this.caminoRoutes});

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      caminoRoutes: json['camino_routes'] != null
          ? (json['camino_routes'] as List)
                .map((i) => CaminoRoute.fromJson(i))
                .toList()
          : null,
    );
  }
}

class CaminoRoute {
  final String? routeId;
  final String? routeName;
  final FilterOptions? filterOptions;
  final List<Stage>? stages;

  CaminoRoute({this.routeId, this.routeName, this.filterOptions, this.stages});

  factory CaminoRoute.fromJson(Map<String, dynamic> json) {
    return CaminoRoute(
      routeId: json['route_id'],
      routeName: json['route_name'],
      filterOptions: json['filter_options'] != null
          ? FilterOptions.fromJson(json['filter_options'])
          : null,
      stages: json['stages'] != null
          ? (json['stages'] as List).map((i) => Stage.fromJson(i)).toList()
          : null,
    );
  }
}

class FilterOptions {
  final String? distanceRange;
  final String? dailyDistancePreference;
  final int? totalDistanceKm;
  final int? totalDays;
  final String? distanceLabel;

  FilterOptions({
    this.distanceRange,
    this.dailyDistancePreference,
    this.totalDistanceKm,
    this.totalDays,
    this.distanceLabel,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      distanceRange: json['distance_range'],
      dailyDistancePreference: json['daily_distance_preference'],
      totalDistanceKm: json['total_distance_km'],
      totalDays: json['total_days'],
      distanceLabel: json['distance_label'],
    );
  }
}

class Stage {
  final int? stageNumber;
  final String? stageName;
  final num? distanceKm;
  final num? distanceMiles;
  final StageDetails? details;
  final List<Facility>? facilities;
  final List<Accommodation>? accommodations;

  Stage({
    this.stageNumber,
    this.stageName,
    this.distanceKm,
    this.distanceMiles,
    this.details,
    this.facilities,
    this.accommodations,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      stageNumber: json['stage_number'],
      stageName: json['stage_name'],
      distanceKm: json['distance_km'],
      distanceMiles: json['distance_miles'],
      details: json['details'] != null
          ? StageDetails.fromJson(json['details'])
          : null,
      facilities: json['facilities'] != null
          ? (json['facilities'] as List)
                .map((i) => Facility.fromJson(i))
                .toList()
          : null,
      accommodations: json['accommodations'] != null
          ? (json['accommodations'] as List)
                .map((i) => Accommodation.fromJson(i))
                .toList()
          : null,
    );
  }
}

class StageDetails {
  final String? totalDistance;
  final String? totalTime;
  final String? accumulatedAscent;
  final String? accumulatedDescent;
  final List<String>? walkingSurface;
  final String? elevationProfile;
  final List<String>? challenges;
  final List<String>? highlights;

  StageDetails({
    this.totalDistance,
    this.totalTime,
    this.accumulatedAscent,
    this.accumulatedDescent,
    this.walkingSurface,
    this.elevationProfile,
    this.challenges,
    this.highlights,
  });

  factory StageDetails.fromJson(Map<String, dynamic> json) {
    return StageDetails(
      totalDistance: json['total_distance'],
      totalTime: json['total_time'],
      accumulatedAscent: json['accumulated_ascent'],
      accumulatedDescent: json['accumulated_descent'],
      walkingSurface: json['walking_surface'] != null
          ? List<String>.from(json['walking_surface'])
          : null,
      elevationProfile: json['elevation_profile'],
      challenges: json['challenges'] != null
          ? List<String>.from(json['challenges'])
          : null,
      highlights: json['highlights'] != null
          ? List<String>.from(json['highlights'])
          : null,
    );
  }
}

class Facility {
  final int? index;
  final List<String>? services;

  Facility({this.index, this.services});

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      index: json['index'],
      services: json['services'] != null
          ? List<String>.from(json['services'])
          : null,
    );
  }
}

class Accommodation {
  final String? name;
  final String? priceCategory;
  final String? contactUrl;
  final String? contactPhone;

  Accommodation({
    this.name,
    this.priceCategory,
    this.contactUrl,
    this.contactPhone,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      name: json['name'],
      priceCategory: json['price_category'],
      contactUrl: json['contact_url'],
      contactPhone: json['contact_phone'],
    );
  }
}
