import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/walk_model.dart';
import '../models/zone_model.dart';
import '../../core/constants/app_constants.dart';

class WalkRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<String> saveWalk(WalkModel walk) async {
    final walkId = walk.id.isEmpty ? _uuid.v4() : walk.id;
    await _firestore
        .collection(AppConstants.walksCollection)
        .doc(walkId)
        .set(walk.toFirestore());

    // Update user stats
    await _updateUserStats(walk);

    return walkId;
  }

  Future<void> _updateUserStats(WalkModel walk) async {
    final userRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(walk.userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;

      final currentSteps = userDoc.data()?['totalSteps'] ?? 0;
      final currentDistance = (userDoc.data()?['totalDistanceM'] ?? 0.0).toDouble();
      final currentCalories = (userDoc.data()?['totalCalories'] ?? 0.0).toDouble();
      final currentWalks = userDoc.data()?['totalWalks'] ?? 0;
      final currentArea = (userDoc.data()?['totalAreaM2'] ?? 0.0).toDouble();

      transaction.update(userRef, {
        'totalSteps': currentSteps + walk.steps,
        'totalDistanceM': currentDistance + walk.distanceM,
        'totalCalories': currentCalories + walk.calories,
        'totalWalks': currentWalks + 1,
        'totalAreaM2': currentArea + walk.areaM2,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  Future<List<WalkModel>> getUserWalks(String userId, {int limit = 20}) async {
    final query = await _firestore
        .collection(AppConstants.walksCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .limit(limit)
        .get();

    return query.docs.map(WalkModel.fromFirestore).toList();
  }

  Future<WalkModel?> getWalk(String walkId) async {
    final doc = await _firestore
        .collection(AppConstants.walksCollection)
        .doc(walkId)
        .get();
    if (!doc.exists) return null;
    return WalkModel.fromFirestore(doc);
  }

  Future<List<WalkModel>> getUserWalksInDateRange(
    String userId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final query = await _firestore
        .collection(AppConstants.walksCollection)
        .where('userId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .orderBy('startTime', descending: true)
        .get();

    return query.docs.map(WalkModel.fromFirestore).toList();
  }

  Future<void> saveZone(ZoneModel zone) async {
    await _firestore
        .collection(AppConstants.zonesCollection)
        .doc(zone.id.isEmpty ? _uuid.v4() : zone.id)
        .set(zone.toFirestore());
  }

  Future<List<ZoneModel>> getUserZones(String userId) async {
    final query = await _firestore
        .collection(AppConstants.zonesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map(ZoneModel.fromFirestore).toList();
  }

  Future<List<ZoneModel>> getFriendZones(List<String> friendIds) async {
    if (friendIds.isEmpty) return [];
    final query = await _firestore
        .collection(AppConstants.zonesCollection)
        .where('userId', whereIn: friendIds.take(10).toList())
        .get();
    return query.docs.map(ZoneModel.fromFirestore).toList();
  }

  Future<void> deleteWalk(String walkId) async {
    await _firestore
        .collection(AppConstants.walksCollection)
        .doc(walkId)
        .delete();
  }
}
