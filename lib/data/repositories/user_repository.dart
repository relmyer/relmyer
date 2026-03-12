import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/friend_request_model.dart';
import '../../core/constants/app_constants.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .update(user.toFirestore());
  }

  Future<String?> uploadProfilePhoto(String userId, File imageFile) async {
    final ref = _storage.ref().child('profile_photos/$userId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .limit(10)
        .get();

    return snapshot.docs.map(UserModel.fromFirestore).toList();
  }

  Future<List<UserModel>> getFriends(List<String> friendIds) async {
    if (friendIds.isEmpty) return [];
    final List<UserModel> friends = [];
    // Firestore whereIn supports max 30
    for (int i = 0; i < friendIds.length; i += 10) {
      final batch = friendIds.skip(i).take(10).toList();
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      friends.addAll(snapshot.docs.map(UserModel.fromFirestore));
    }
    return friends;
  }

  Future<void> sendFriendRequest({
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhotoUrl,
    required String toUserId,
  }) async {
    final request = FriendRequestModel(
      id: '',
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserPhotoUrl: fromUserPhotoUrl,
      toUserId: toUserId,
      status: FriendRequestStatus.pending,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection(AppConstants.friendRequestsCollection)
        .add(request.toFirestore());
  }

  Future<List<FriendRequestModel>> getPendingRequests(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.friendRequestsCollection)
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs.map(FriendRequestModel.fromFirestore).toList();
  }

  Future<void> acceptFriendRequest(FriendRequestModel request) async {
    final batch = _firestore.batch();

    // Update request status
    batch.update(
      _firestore
          .collection(AppConstants.friendRequestsCollection)
          .doc(request.id),
      {'status': 'accepted'},
    );

    // Add to both users' friend lists
    batch.update(
      _firestore
          .collection(AppConstants.usersCollection)
          .doc(request.fromUserId),
      {
        'friendIds': FieldValue.arrayUnion([request.toUserId]),
      },
    );
    batch.update(
      _firestore
          .collection(AppConstants.usersCollection)
          .doc(request.toUserId),
      {
        'friendIds': FieldValue.arrayUnion([request.fromUserId]),
      },
    );

    await batch.commit();
  }

  Future<void> declineFriendRequest(String requestId) async {
    await _firestore
        .collection(AppConstants.friendRequestsCollection)
        .doc(requestId)
        .update({'status': 'declined'});
  }

  Future<void> removeFriend(String userId, String friendId) async {
    final batch = _firestore.batch();
    batch.update(
      _firestore.collection(AppConstants.usersCollection).doc(userId),
      {'friendIds': FieldValue.arrayRemove([friendId])},
    );
    batch.update(
      _firestore.collection(AppConstants.usersCollection).doc(friendId),
      {'friendIds': FieldValue.arrayRemove([userId])},
    );
    await batch.commit();
  }

  Stream<List<FriendRequestModel>> pendingRequestsStream(String userId) {
    return _firestore
        .collection(AppConstants.friendRequestsCollection)
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) =>
            snap.docs.map(FriendRequestModel.fromFirestore).toList());
  }
}
