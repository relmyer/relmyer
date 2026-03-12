import 'package:cloud_firestore/cloud_firestore.dart';

enum PlanStatus { active, paused, completed }

class TrainingExercise {
  final String id;
  final String title;
  final String description;
  final String technique;        // e.g., "counter-conditioning", "desensitization"
  final int durationMinutes;
  final int difficultyLevel;     // 1-5
  final List<String> steps;
  final List<String> materials;  // What you need (treats, clicker, etc.)
  final String successCriteria;
  bool isCompleted;
  DateTime? completedAt;

  TrainingExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.technique,
    this.durationMinutes = 5,
    this.difficultyLevel = 1,
    this.steps = const [],
    this.materials = const [],
    required this.successCriteria,
    this.isCompleted = false,
    this.completedAt,
  });

  factory TrainingExercise.fromMap(Map<String, dynamic> map) {
    return TrainingExercise(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      technique: map['technique'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 5,
      difficultyLevel: map['difficultyLevel'] ?? 1,
      steps: List<String>.from(map['steps'] ?? []),
      materials: List<String>.from(map['materials'] ?? []),
      successCriteria: map['successCriteria'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'technique': technique,
    'durationMinutes': durationMinutes,
    'difficultyLevel': difficultyLevel,
    'steps': steps,
    'materials': materials,
    'successCriteria': successCriteria,
    'isCompleted': isCompleted,
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
  };
}

class TrainingWeek {
  final int weekNumber;
  final String goal;
  final String focusTrigger;
  final List<TrainingExercise> exercises;
  final String notes;           // Claude-generated week notes
  bool isCompleted;

  TrainingWeek({
    required this.weekNumber,
    required this.goal,
    required this.focusTrigger,
    required this.exercises,
    required this.notes,
    this.isCompleted = false,
  });

  double get completionPercentage {
    if (exercises.isEmpty) return 0;
    return exercises.where((e) => e.isCompleted).length / exercises.length;
  }
}

class TrainingPlan {
  final String id;
  final String dogId;
  final String ownerId;
  final String title;
  final String description;           // Claude-generated overview
  final String targetTrigger;
  final int totalWeeks;
  final List<TrainingWeek> weeks;
  final PlanStatus status;
  final String approach;              // e.g., "BAT 2.0", "LAT", "CC+DS"
  final List<String> importantNotes;  // Safety & important reminders
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  TrainingPlan({
    required this.id,
    required this.dogId,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.targetTrigger,
    required this.totalWeeks,
    required this.weeks,
    this.status = PlanStatus.active,
    required this.approach,
    this.importantNotes = const [],
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  int get currentWeek {
    if (startedAt == null) return 1;
    final daysSinceStart = DateTime.now().difference(startedAt!).inDays;
    return (daysSinceStart / 7).floor() + 1;
  }

  double get overallProgress {
    if (weeks.isEmpty) return 0;
    final completed = weeks.where((w) => w.isCompleted).length;
    return completed / weeks.length;
  }

  factory TrainingPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainingPlan(
      id: doc.id,
      dogId: data['dogId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      targetTrigger: data['targetTrigger'] ?? '',
      totalWeeks: data['totalWeeks'] ?? 4,
      weeks: [], // Loaded separately from subcollection
      status: PlanStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PlanStatus.active,
      ),
      approach: data['approach'] ?? '',
      importantNotes: List<String>.from(data['importantNotes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      startedAt: data['startedAt'] != null
          ? (data['startedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'dogId': dogId,
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'targetTrigger': targetTrigger,
    'totalWeeks': totalWeeks,
    'status': status.name,
    'approach': approach,
    'importantNotes': importantNotes,
    'createdAt': Timestamp.fromDate(createdAt),
    'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
  };
}
