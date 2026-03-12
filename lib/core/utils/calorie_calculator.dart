class CalorieCalculator {
  CalorieCalculator._();

  /// Calculates calories burned based on MET formula.
  /// MET (Metabolic Equivalent of Task) for walking ~3.5 km/h = 3.5
  /// Calories = MET × weight(kg) × time(hours)
  static double calculate({
    required double distanceKm,
    required int durationSeconds,
    required double weightKg,
  }) {
    if (durationSeconds == 0 || distanceKm == 0) return 0;

    final double speedKmH = distanceKm / (durationSeconds / 3600.0);

    // MET based on walking speed
    double met;
    if (speedKmH < 3.2) {
      met = 2.8; // slow walk
    } else if (speedKmH < 4.8) {
      met = 3.5; // moderate walk
    } else if (speedKmH < 6.4) {
      met = 4.3; // brisk walk
    } else {
      met = 5.0; // very brisk / power walk
    }

    final double durationHours = durationSeconds / 3600.0;
    return met * weightKg * durationHours;
  }

  /// Simple estimation from steps
  static double fromSteps({
    required int steps,
    required double weightKg,
  }) {
    // ~0.04 kcal per step for average person (~70kg)
    final double factor = weightKg / 70.0 * 0.04;
    return steps * factor;
  }
}
