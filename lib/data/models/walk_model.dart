import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum WalkType { solo, group }

class WalkModel {
  final String id;
  final String userId;
  final WalkType type;
  final List<String> participantIds; // for group walks
  final List<LatLng> routePoints;
  final double distanceM;
  final int steps;
  final double calories;
  final int durationSeconds;
  final DateTime startTime;
  final DateTime? endTime;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final double areaM2; // area of bounding polygon
  final List<List<LatLng>> zonePolygons; // marked zone polygons
  final String? notes;
  final bool isSaved;

  const WalkModel({
    required this.id,
    required this.userId,
    required this.type,
    this.participantIds = const [],
    required this.routePoints,
    required this.distanceM,
    required this.steps,
    required this.calories,
    required this.durationSeconds,
    required this.startTime,
    this.endTime,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    this.areaM2 = 0.0,
    this.zonePolygons = const [],
    this.notes,
    this.isSaved = false,
  });

  factory WalkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Deserialize route points
    final List<dynamic> rawRoute = data['routePoints'] ?? [];
    final List<LatLng> route = rawRoute
        .map((p) => LatLng(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            ))
        .toList();

    // Deserialize zone polygons
    final List<dynamic> rawZones = data['zonePolygons'] ?? [];
    final List<List<LatLng>> zones = rawZones.map((zone) {
      final List<dynamic> points = zone as List<dynamic>;
      return points
          .map((p) => LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              ))
          .toList();
    }).toList();

    return WalkModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] == 'group' ? WalkType.group : WalkType.solo,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      routePoints: route,
      distanceM: (data['distanceM'] ?? 0.0).toDouble(),
      steps: data['steps'] ?? 0,
      calories: (data['calories'] ?? 0.0).toDouble(),
      durationSeconds: data['durationSeconds'] ?? 0,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      startLat: (data['startLat'] ?? 0.0).toDouble(),
      startLng: (data['startLng'] ?? 0.0).toDouble(),
      endLat: (data['endLat'] ?? 0.0).toDouble(),
      endLng: (data['endLng'] ?? 0.0).toDouble(),
      areaM2: (data['areaM2'] ?? 0.0).toDouble(),
      zonePolygons: zones,
      notes: data['notes'],
      isSaved: data['isSaved'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type == WalkType.group ? 'group' : 'solo',
      'participantIds': participantIds,
      'routePoints': routePoints
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
      'distanceM': distanceM,
      'steps': steps,
      'calories': calories,
      'durationSeconds': durationSeconds,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'startLat': startLat,
      'startLng': startLng,
      'endLat': endLat,
      'endLng': endLng,
      'areaM2': areaM2,
      'zonePolygons': zonePolygons
          .map((zone) =>
              zone.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList())
          .toList(),
      'notes': notes,
      'isSaved': isSaved,
    };
  }

  WalkModel copyWith({
    List<LatLng>? routePoints,
    double? distanceM,
    int? steps,
    double? calories,
    int? durationSeconds,
    DateTime? endTime,
    double? endLat,
    double? endLng,
    double? areaM2,
    List<List<LatLng>>? zonePolygons,
    bool? isSaved,
    String? notes,
  }) {
    return WalkModel(
      id: id,
      userId: userId,
      type: type,
      participantIds: participantIds,
      routePoints: routePoints ?? this.routePoints,
      distanceM: distanceM ?? this.distanceM,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      startLat: startLat,
      startLng: startLng,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      areaM2: areaM2 ?? this.areaM2,
      zonePolygons: zonePolygons ?? this.zonePolygons,
      notes: notes ?? this.notes,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
