import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/models/friend_request_model.dart';
import '../../data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();

  List<UserModel> _friends = [];
  List<FriendRequestModel> _pendingRequests = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get friends => _friends;
  List<FriendRequestModel> get pendingRequests => _pendingRequests;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFriends(List<String> friendIds) async {
    _isLoading = true;
    notifyListeners();
    _friends = await _repository.getFriends(friendIds);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPendingRequests(String userId) async {
    _pendingRequests = await _repository.getPendingRequests(userId);
    notifyListeners();
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    _searchResults = await _repository.searchUsers(query.trim());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendFriendRequest({
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhotoUrl,
    required String toUserId,
  }) async {
    await _repository.sendFriendRequest(
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserPhotoUrl: fromUserPhotoUrl,
      toUserId: toUserId,
    );
  }

  Future<void> acceptRequest(FriendRequestModel request) async {
    await _repository.acceptFriendRequest(request);
    _pendingRequests.removeWhere((r) => r.id == request.id);
    notifyListeners();
  }

  Future<void> declineRequest(String requestId) async {
    await _repository.declineFriendRequest(requestId);
    _pendingRequests.removeWhere((r) => r.id == requestId);
    notifyListeners();
  }

  Future<void> removeFriend(String userId, String friendId) async {
    await _repository.removeFriend(userId, friendId);
    _friends.removeWhere((f) => f.id == friendId);
    notifyListeners();
  }

  Future<String?> uploadProfilePhoto(String userId, File imageFile) async {
    return await _repository.uploadProfilePhoto(userId, imageFile);
  }

  Future<void> updateUser(UserModel user) async {
    await _repository.updateUser(user);
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
