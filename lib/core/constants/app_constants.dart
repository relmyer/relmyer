class AppConstants {
  AppConstants._();

  static const String appName = 'StepSphere';
  static const String appVersion = '1.0.0';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String walksCollection = 'walks';
  static const String zonesCollection = 'zones';
  static const String friendshipsCollection = 'friendships';
  static const String friendRequestsCollection = 'friend_requests';
  static const String leaderboardCollection = 'leaderboard';

  // SharedPreferences keys
  static const String keyUserId = 'user_id';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyThemeMode = 'theme_mode';
  static const String keyUnitSystem = 'unit_system';
  static const String keyWeightKg = 'weight_kg';
  static const String keyHeightCm = 'height_cm';

  // Default values
  static const double defaultWeightKg = 70.0;
  static const double defaultHeightCm = 170.0;
  static const double stepLengthM = 0.762; // average step length in meters
  static const int caloriesPerKm = 60; // approx calories burned per km

  // Walk tracking
  static const int locationUpdateIntervalMs = 3000;
  static const double minDistanceFilterM = 5.0;
  static const double minZoneAreaM2 = 10000.0; // 10,000 m² = ~1 hectare

  // Map
  static const double defaultMapZoom = 16.0;
  static const double routeLineWidth = 4.0;

  // Pagination
  static const int walksPageSize = 20;

  // Achievements thresholds (steps)
  static const int achievementBronze = 10000;
  static const int achievementSilver = 50000;
  static const int achievementGold = 100000;
  static const int achievementDiamond = 500000;

  // Google Maps API Key placeholder
  static const String googleMapsApiKeyAndroid = 'YOUR_ANDROID_MAPS_API_KEY';
  static const String googleMapsApiKeyIos = 'YOUR_IOS_MAPS_API_KEY';
}
