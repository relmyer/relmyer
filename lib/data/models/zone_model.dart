import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ZoneModel {
  final String id;
  final String userId;
  final String walkId;
  final List<LatLng> polygon;
  final double areaM2;
  final DateTime createdAt;
  final String? label;

  const ZoneModel({
    required this.id,
    required this.userId,
    required this.walkId,
    required this.polygon,
    required this.areaM2,
    required this.createdAt,
    this.label,
  });

  factory ZoneModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> rawPolygon = data['polygon'] ?? [];
    return ZoneModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      walkId: data['walkId'] ?? '',
      polygon: rawPolygon
          .map((p) => LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              ))
          .toList(),
      areaM2: (data['areaM2'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      label: data['label'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'walkId': walkId,
      'polygon':
          polygon.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'areaM2': areaM2,
      'createdAt': Timestamp.fromDate(createdAt),
      'label': label,
    };
  }
}
