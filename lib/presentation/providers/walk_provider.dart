import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/walk_model.dart';
import '../../data/repositories/walk_repository.dart';
import '../../data/services/location_service.dart';
import '../../data/services/pedometer_service.dart';
import '../../core/utils/calorie_calculator.dart';
import '../../core/utils/distance_calculator.dart';

enum WalkState { idle, active, paused, completed }

class WalkProvider extends ChangeNotifier {
  final WalkRepository _repository = WalkRepository();
  final LocationService _locationService = LocationService();
  final PedometerService _pedometerService = PedometerService();
  final _uuid = const Uuid();

  WalkState _walkState = WalkState.idle;
  WalkType _walkType = WalkType.solo;
  List<LatLng> _routePoints = [];
  double _distanceM = 0;
  int _steps = 0;
  double _calories = 0;
  int _durationSeconds = 0;
  DateTime? _startTime;
  List<WalkModel> _walkHistory = [];
  bool _isLoadingHistory = false;
  String? _currentWalkId;

  StreamSubscription<LatLng>? _locationSub;
  StreamSubscription<int>? _stepSub;
  Timer? _durationTimer;

  WalkState get walkState => _walkState;
  WalkType get walkType => _walkType;
  List<LatLng> get routePoints => _routePoints;
  double get distanceM => _distanceM;
  int get steps => _steps;
  double get calories => _calories;
  int get durationSeconds => _durationSeconds;
  DateTime? get startTime => _startTime;
  List<WalkModel> get walkHistory => _walkHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isActive => _walkState == WalkState.active;
  bool get isPaused => _walkState == WalkState.paused;

  LatLng? get lastPosition =>
      _routePoints.isNotEmpty ? _routePoints.last : null;

  Future<bool> startWalk({
    required WalkType type,
    required String userId,
    required double weightKg,
    List<String> participantIds = const [],
  }) async {
    final hasPermission = await _locationService.requestPermission();
    if (!hasPermission) return false;

    final currentPos = await _locationService.getCurrentLocation();
    if (currentPos == null) return false;

    _walkType = type;
    _walkState = WalkState.active;
    _routePoints = [currentPos];
    _distanceM = 0;
    _steps = 0;
    _calories = 0;
    _durationSeconds = 0;
    _startTime = DateTime.now();
    _currentWalkId = _uuid.v4();

    _locationService.startTracking();
    _pedometerService.startTracking();

    // Listen to location
    _locationSub = _locationService.locationStream.listen((LatLng pos) {
      if (_walkState != WalkState.active) return;
      if (_routePoints.isNotEmpty) {
        final double delta = DistanceCalculator.haversine(_routePoints.last, pos);
        if (delta > 2) {
          // Only add if moved > 2m
          _distanceM += delta;
          _routePoints.add(pos);

          // Update calories
          _calories = CalorieCalculator.calculate(
            distanceKm: _distanceM / 1000,
            durationSeconds: _durationSeconds,
            weightKg: weightKg,
          );

          notifyListeners();
        }
      }
    });

    // Listen to steps
    _stepSub = _pedometerService.stepStream.listen((int count) {
      _steps = count;
      notifyListeners();
    });

    // Duration timer
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_walkState == WalkState.active) {
        _durationSeconds++;
        notifyListeners();
      }
    });

    notifyListeners();
    return true;
  }

  void pauseWalk() {
    if (_walkState != WalkState.active) return;
    _walkState = WalkState.paused;
    notifyListeners();
  }

  void resumeWalk() {
    if (_walkState != WalkState.paused) return;
    _walkState = WalkState.active;
    notifyListeners();
  }

  Future<WalkModel?> finishWalk({required String userId}) async {
    if (_walkState == WalkState.idle) return null;

    _walkState = WalkState.completed;
    _locationService.stopTracking();
    _pedometerService.stopTracking();
    _locationSub?.cancel();
    _stepSub?.cancel();
    _durationTimer?.cancel();

    if (_routePoints.isEmpty) return null;

    final endPos = _routePoints.last;
    final startPos = _routePoints.first;

    // Build convex-hull-like polygon from route for area calculation
    final double areaM2 = _routePoints.length >= 3
        ? DistanceCalculator.polygonArea(_routePoints)
        : 0.0;

    final walk = WalkModel(
      id: _currentWalkId!,
      userId: userId,
      type: _walkType,
      routePoints: List.from(_routePoints),
      distanceM: _distanceM,
      steps: _steps,
      calories: _calories,
      durationSeconds: _durationSeconds,
      startTime: _startTime!,
      endTime: DateTime.now(),
      startLat: startPos.latitude,
      startLng: startPos.longitude,
      endLat: endPos.latitude,
      endLng: endPos.longitude,
      areaM2: areaM2,
      isSaved: true,
    );

    await _repository.saveWalk(walk);

    // Prepend to history
    _walkHistory.insert(0, walk);

    notifyListeners();
    return walk;
  }

  void cancelWalk() {
    _walkState = WalkState.idle;
    _locationService.stopTracking();
    _pedometerService.stopTracking();
    _locationSub?.cancel();
    _stepSub?.cancel();
    _durationTimer?.cancel();
    _routePoints = [];
    _distanceM = 0;
    _steps = 0;
    _calories = 0;
    _durationSeconds = 0;
    notifyListeners();
  }

  Future<void> loadWalkHistory(String userId) async {
    _isLoadingHistory = true;
    notifyListeners();

    _walkHistory = await _repository.getUserWalks(userId);

    _isLoadingHistory = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _stepSub?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}
