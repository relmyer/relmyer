import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  void _init() {
    _repository.authStateChanges.listen((User? user) async {
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
      } else {
        _status = AuthStatus.loading;
        notifyListeners();
        _currentUser = await _repository.getCurrentUserModel();
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e.code);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _repository.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e.code);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void updateCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu e-posta zaten kullanılıyor.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'weak-password':
        return 'Şifre çok zayıf.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre.';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen bekleyin.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
