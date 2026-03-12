import 'dart:async';
import 'package:pedometer/pedometer.dart';

class PedometerService {
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();

  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianSubscription;

  final StreamController<int> _stepController =
      StreamController<int>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  Stream<int> get stepStream => _stepController.stream;
  Stream<String> get statusStream => _statusController.stream;

  int _sessionSteps = 0;
  int? _initialStepCount;
  bool _isTracking = false;

  int get sessionSteps => _sessionSteps;

  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;
    _initialStepCount = null;
    _sessionSteps = 0;

    _stepCountSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        _initialStepCount ??= event.steps;
        _sessionSteps = event.steps - _initialStepCount!;
        if (_sessionSteps < 0) _sessionSteps = 0;
        _stepController.add(_sessionSteps);
      },
      onError: (_) {
        // Pedometer not available, use distance-based estimation
      },
    );

    _pedestrianSubscription = Pedometer.pedestrianStatusStream.listen(
      (PedestrianStatus event) {
        _statusController.add(event.status);
      },
      onError: (_) {},
    );
  }

  void stopTracking() {
    _isTracking = false;
    _stepCountSubscription?.cancel();
    _pedestrianSubscription?.cancel();
    _stepCountSubscription = null;
    _pedestrianSubscription = null;
  }

  void reset() {
    _sessionSteps = 0;
    _initialStepCount = null;
  }

  void dispose() {
    stopTracking();
    _stepController.close();
    _statusController.close();
  }
}
