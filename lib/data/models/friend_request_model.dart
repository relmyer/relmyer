import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendRequestStatus { pending, accepted, declined }

class FriendRequestModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPhotoUrl;
  final String toUserId;
  final FriendRequestStatus status;
  final DateTime createdAt;

  const FriendRequestModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserPhotoUrl,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    FriendRequestStatus status;
    switch (data['status']) {
      case 'accepted':
        status = FriendRequestStatus.accepted;
        break;
      case 'declined':
        status = FriendRequestStatus.declined;
        break;
      default:
        status = FriendRequestStatus.pending;
    }
    return FriendRequestModel(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? '',
      fromUserPhotoUrl: data['fromUserPhotoUrl'],
      toUserId: data['toUserId'] ?? '',
      status: status,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    String statusStr;
    switch (status) {
      case FriendRequestStatus.accepted:
        statusStr = 'accepted';
        break;
      case FriendRequestStatus.declined:
        statusStr = 'declined';
        break;
      default:
        statusStr = 'pending';
    }
    return {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserPhotoUrl': fromUserPhotoUrl,
      'toUserId': toUserId,
      'status': statusStr,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
