import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DistanceCalculator {
  DistanceCalculator._();

  static const double _earthRadiusKm = 6371.0;

  /// Haversine formula - calculates distance between two GPS points in meters
  static double haversine(LatLng from, LatLng to) {
    final double lat1 = _toRadians(from.latitude);
    final double lat2 = _toRadians(to.latitude);
    final double dLat = _toRadians(to.latitude - from.latitude);
    final double dLon = _toRadians(to.longitude - from.longitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c * 1000; // meters
  }

  /// Total distance of a route in meters
  static double totalDistance(List<LatLng> points) {
    if (points.length < 2) return 0;
    double total = 0;
    for (int i = 0; i < points.length - 1; i++) {
      total += haversine(points[i], points[i + 1]);
    }
    return total;
  }

  /// Estimated steps from distance
  static int distanceToSteps(double distanceM, {double stepLengthM = 0.762}) {
    return (distanceM / stepLengthM).round();
  }

  /// Format distance for display
  static String formatDistance(double distanceM, {bool metric = true}) {
    if (metric) {
      if (distanceM >= 1000) {
        return '${(distanceM / 1000).toStringAsFixed(2)} km';
      }
      return '${distanceM.toStringAsFixed(0)} m';
    } else {
      final double miles = distanceM / 1609.34;
      return '${miles.toStringAsFixed(2)} mi';
    }
  }

  /// Format duration for display
  static String formatDuration(int seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = seconds % 60;

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Pace in min/km
  static String formatPace(double distanceM, int durationSeconds) {
    if (distanceM == 0) return '--:--';
    final double paceSecPerKm = (durationSeconds / (distanceM / 1000));
    final int min = paceSecPerKm ~/ 60;
    final int sec = (paceSecPerKm % 60).round();
    return '${min}:${sec.toString().padLeft(2, '0')}';
  }

  /// Calculate approximate polygon area using Shoelace formula (in m²)
  static double polygonArea(List<LatLng> polygon) {
    if (polygon.length < 3) return 0;

    // Convert to approximate Cartesian using equirectangular projection
    final double refLat = polygon[0].latitude;
    final double latRad = _toRadians(refLat);

    List<_Point> points = polygon.map((p) {
      final double x = _toRadians(p.longitude - polygon[0].longitude) *
          _earthRadiusKm *
          1000 *
          cos(latRad);
      final double y =
          _toRadians(p.latitude - polygon[0].latitude) * _earthRadiusKm * 1000;
      return _Point(x, y);
    }).toList();

    double area = 0;
    int n = points.length;
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      area += points[i].x * points[j].y;
      area -= points[j].x * points[i].y;
    }
    return (area / 2).abs();
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}

class _Point {
  final double x;
  final double y;
  const _Point(this.x, this.y);
}
