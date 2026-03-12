import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/calm_spot.dart';

class SpotService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'calm_spots';

  /// Get nearby spots filtered by calm score
  Stream<List<CalmSpot>> getNearbySpots({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
    int minCalmScore = 1,
    SpotType? type,
  }) {
    Query query = _db.collection(_collection);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    return query.snapshots().map((snapshot) {
      final spots = snapshot.docs
          .map((doc) => CalmSpot.fromFirestore(doc))
          .where((spot) {
            final distanceKm = Geolocator.distanceBetween(
              lat, lng,
              spot.location.latitude, spot.location.longitude,
            ) / 1000;
            return distanceKm <= radiusKm &&
                spot.avgCalmScore >= minCalmScore;
          })
          .toList();

      // Sort by calm score (highest first), then by distance
      spots.sort((a, b) {
        final calmCompare = b.avgCalmScore.compareTo(a.avgCalmScore);
        if (calmCompare != 0) return calmCompare;
        final distA = Geolocator.distanceBetween(lat, lng,
            a.location.latitude, a.location.longitude);
        final distB = Geolocator.distanceBetween(lat, lng,
            b.location.latitude, b.location.longitude);
        return distA.compareTo(distB);
      });

      return spots;
    });
  }

  /// Get a single spot by ID
  Future<CalmSpot?> getSpot(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return CalmSpot.fromFirestore(doc);
  }

  /// Add a new spot
  Future<String> addSpot(CalmSpot spot) async {
    final docRef = await _db.collection(_collection).add(spot.toFirestore());
    return docRef.id;
  }

  /// Submit a live calm report for a spot
  Future<void> submitLiveReport({
    required String spotId,
    required String userId,
    required int calmScore,
    String? note,
  }) async {
    final report = LiveReport(
      userId: userId,
      calmScore: calmScore,
      note: note,
      reportedAt: DateTime.now(),
    );

    await _db.collection(_collection).doc(spotId).update({
      'liveReports': FieldValue.arrayUnion([report.toMap()]),
    });
  }

  /// Add a community tip to a spot
  Future<void> addTip({
    required String spotId,
    required String tip,
  }) async {
    await _db.collection(_collection).doc(spotId).update({
      'tips': FieldValue.arrayUnion([tip]),
    });
  }

  /// Rate a spot
  Future<void> rateSpot({
    required String spotId,
    required int calmScore,
    required int noiseLevel,
    required int crowdLevel,
    required int dogEncounterLevel,
  }) async {
    // Get current spot data for averaging
    final doc = await _db.collection(_collection).doc(spotId).get();
    final data = doc.data()!;
    final currentCount = (data['reviewCount'] as int? ?? 0);
    final currentCalm = (data['avgCalmScore'] as num? ?? 3.0).toDouble();

    // Calculate new average
    final newCalm = ((currentCalm * currentCount) + calmScore) / (currentCount + 1);

    await _db.collection(_collection).doc(spotId).update({
      'avgCalmScore': newCalm,
      'noiseLevel': noiseLevel,
      'crowdLevel': crowdLevel,
      'dogEncounterLevel': dogEncounterLevel,
      'reviewCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get current user location
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
