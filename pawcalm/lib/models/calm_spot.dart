import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum SpotType {
  quietPark,
  offLeashArea,
  trailPath,
  beach,
  cafe,
  petShop,
  vetClinic,
  trainingCenter,
  other,
}

class LiveReport {
  final String userId;
  final int calmScore;      // 1-5 (5 = very calm right now)
  final String? note;
  final DateTime reportedAt;

  const LiveReport({
    required this.userId,
    required this.calmScore,
    this.note,
    required this.reportedAt,
  });

  factory LiveReport.fromMap(Map<String, dynamic> map) {
    return LiveReport(
      userId: map['userId'] ?? '',
      calmScore: map['calmScore'] ?? 3,
      note: map['note'],
      reportedAt: (map['reportedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'calmScore': calmScore,
    'note': note,
    'reportedAt': Timestamp.fromDate(reportedAt),
  };
}

class CalmSpot {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final SpotType type;
  final double avgCalmScore;     // 1.0 - 5.0 (5 = very calm)
  final int noiseLevel;          // 1-5 (1 = very quiet)
  final int crowdLevel;          // 1-5 (1 = very empty)
  final int dogEncounterLevel;   // 1-5 (1 = very few dogs)
  final bool isOffLeash;
  final bool hasFreshWater;
  final bool isFenced;
  final bool isShaded;
  final List<String> photos;
  final List<String> tips;          // Community tips for reactive dog owners
  final List<LiveReport> liveReports; // Last 2 hours of reports
  final int reviewCount;
  final String? addedByUserId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CalmSpot({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.type,
    this.avgCalmScore = 3.0,
    this.noiseLevel = 3,
    this.crowdLevel = 3,
    this.dogEncounterLevel = 3,
    this.isOffLeash = false,
    this.hasFreshWater = false,
    this.isFenced = false,
    this.isShaded = false,
    this.photos = const [],
    this.tips = const [],
    this.liveReports = const [],
    this.reviewCount = 0,
    this.addedByUserId,
    required this.createdAt,
    this.updatedAt,
  });

  // The "calm now" score based on recent live reports (last 2 hours)
  double? get currentCalmScore {
    if (liveReports.isEmpty) return null;
    final recent = liveReports.where(
      (r) => DateTime.now().difference(r.reportedAt).inHours < 2,
    ).toList();
    if (recent.isEmpty) return null;
    return recent.map((r) => r.calmScore).reduce((a, b) => a + b) / recent.length;
  }

  String get typeLabel {
    switch (type) {
      case SpotType.quietPark: return 'Sakin Park';
      case SpotType.offLeashArea: return 'Tasmasız Alan';
      case SpotType.trailPath: return 'Yürüyüş Yolu';
      case SpotType.beach: return 'Plaj';
      case SpotType.cafe: return 'Kafe';
      case SpotType.petShop: return 'Pet Shop';
      case SpotType.vetClinic: return 'Veteriner';
      case SpotType.trainingCenter: return 'Eğitim Merkezi';
      case SpotType.other: return 'Diğer';
    }
  }

  String get typeEmoji {
    switch (type) {
      case SpotType.quietPark: return '🌿';
      case SpotType.offLeashArea: return '🐾';
      case SpotType.trailPath: return '🌲';
      case SpotType.beach: return '🏖️';
      case SpotType.cafe: return '☕';
      case SpotType.petShop: return '🛍️';
      case SpotType.vetClinic: return '🏥';
      case SpotType.trainingCenter: return '🎓';
      case SpotType.other: return '📍';
    }
  }

  factory CalmSpot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geoPoint = data['location'] as GeoPoint;
    return CalmSpot(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      type: SpotType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => SpotType.other,
      ),
      avgCalmScore: (data['avgCalmScore'] ?? 3.0).toDouble(),
      noiseLevel: data['noiseLevel'] ?? 3,
      crowdLevel: data['crowdLevel'] ?? 3,
      dogEncounterLevel: data['dogEncounterLevel'] ?? 3,
      isOffLeash: data['isOffLeash'] ?? false,
      hasFreshWater: data['hasFreshWater'] ?? false,
      isFenced: data['isFenced'] ?? false,
      isShaded: data['isShaded'] ?? false,
      photos: List<String>.from(data['photos'] ?? []),
      tips: List<String>.from(data['tips'] ?? []),
      liveReports: (data['liveReports'] as List<dynamic>? ?? [])
          .map((r) => LiveReport.fromMap(r as Map<String, dynamic>))
          .toList(),
      reviewCount: data['reviewCount'] ?? 0,
      addedByUserId: data['addedByUserId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'location': GeoPoint(location.latitude, location.longitude),
      'type': type.name,
      'avgCalmScore': avgCalmScore,
      'noiseLevel': noiseLevel,
      'crowdLevel': crowdLevel,
      'dogEncounterLevel': dogEncounterLevel,
      'isOffLeash': isOffLeash,
      'hasFreshWater': hasFreshWater,
      'isFenced': isFenced,
      'isShaded': isShaded,
      'photos': photos,
      'tips': tips,
      'liveReports': liveReports.map((r) => r.toMap()).toList(),
      'reviewCount': reviewCount,
      'addedByUserId': addedByUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
