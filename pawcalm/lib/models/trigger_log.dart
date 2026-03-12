import 'package:cloud_firestore/cloud_firestore.dart';

enum ReactionIntensity { none, mild, moderate, severe, extreme }
enum RecoveryTime { under1min, onetofive, fivetoFifteen, overFifteen }

class TriggerLog {
  final String id;
  final String dogId;
  final String ownerId;
  final DateTime date;
  final String trigger;              // What triggered the dog
  final String? triggerDetails;      // More specific description
  final ReactionIntensity intensity;
  final RecoveryTime recoveryTime;
  final double distanceToTrigger;    // In meters
  final String? location;            // Where it happened
  final bool usedCalming;            // Did owner use a calming technique?
  final String? calmingTechnique;    // Which technique
  final bool treatUsed;
  final String? notes;
  final String? spotId;              // If happened at a CalmSpot
  final int moodBefore;              // 1-5 dog's mood before walk
  final int moodAfter;               // 1-5 dog's mood after

  TriggerLog({
    required this.id,
    required this.dogId,
    required this.ownerId,
    required this.date,
    required this.trigger,
    this.triggerDetails,
    this.intensity = ReactionIntensity.moderate,
    this.recoveryTime = RecoveryTime.onetofive,
    this.distanceToTrigger = 10,
    this.location,
    this.usedCalming = false,
    this.calmingTechnique,
    this.treatUsed = false,
    this.notes,
    this.spotId,
    this.moodBefore = 3,
    this.moodAfter = 3,
  });

  String get intensityLabel {
    switch (intensity) {
      case ReactionIntensity.none: return 'Tepki Yok';
      case ReactionIntensity.mild: return 'Hafif';
      case ReactionIntensity.moderate: return 'Orta';
      case ReactionIntensity.severe: return 'Şiddetli';
      case ReactionIntensity.extreme: return 'Çok Şiddetli';
    }
  }

  String get recoveryLabel {
    switch (recoveryTime) {
      case RecoveryTime.under1min: return '< 1 dakika';
      case RecoveryTime.onetofive: return '1-5 dakika';
      case RecoveryTime.fivetoFifteen: return '5-15 dakika';
      case RecoveryTime.overFifteen: return '15+ dakika';
    }
  }

  // Progress score (higher = better)
  int get progressScore {
    int score = 0;
    switch (intensity) {
      case ReactionIntensity.none: score += 5;
      case ReactionIntensity.mild: score += 4;
      case ReactionIntensity.moderate: score += 3;
      case ReactionIntensity.severe: score += 2;
      case ReactionIntensity.extreme: score += 1;
    }
    switch (recoveryTime) {
      case RecoveryTime.under1min: score += 4;
      case RecoveryTime.onetofive: score += 3;
      case RecoveryTime.fivetoFifteen: score += 2;
      case RecoveryTime.overFifteen: score += 1;
    }
    return score;
  }

  factory TriggerLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TriggerLog(
      id: doc.id,
      dogId: data['dogId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      trigger: data['trigger'] ?? '',
      triggerDetails: data['triggerDetails'],
      intensity: ReactionIntensity.values.firstWhere(
        (e) => e.name == data['intensity'],
        orElse: () => ReactionIntensity.moderate,
      ),
      recoveryTime: RecoveryTime.values.firstWhere(
        (e) => e.name == data['recoveryTime'],
        orElse: () => RecoveryTime.onetofive,
      ),
      distanceToTrigger: (data['distanceToTrigger'] ?? 10).toDouble(),
      location: data['location'],
      usedCalming: data['usedCalming'] ?? false,
      calmingTechnique: data['calmingTechnique'],
      treatUsed: data['treatUsed'] ?? false,
      notes: data['notes'],
      spotId: data['spotId'],
      moodBefore: data['moodBefore'] ?? 3,
      moodAfter: data['moodAfter'] ?? 3,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dogId': dogId,
      'ownerId': ownerId,
      'date': Timestamp.fromDate(date),
      'trigger': trigger,
      'triggerDetails': triggerDetails,
      'intensity': intensity.name,
      'recoveryTime': recoveryTime.name,
      'distanceToTrigger': distanceToTrigger,
      'location': location,
      'usedCalming': usedCalming,
      'calmingTechnique': calmingTechnique,
      'treatUsed': treatUsed,
      'notes': notes,
      'spotId': spotId,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
    };
  }
}

// Summary of a dog's training progress
class ProgressSummary {
  final String dogId;
  final int totalLogs;
  final double avgProgressScore;
  final Map<String, int> triggerFrequency;      // trigger -> count
  final Map<String, double> triggerImprovement; // trigger -> trend (-1 to 1)
  final double thresholdDistance;               // current safe distance to triggers
  final List<TriggerLog> recentLogs;

  ProgressSummary({
    required this.dogId,
    required this.totalLogs,
    required this.avgProgressScore,
    required this.triggerFrequency,
    required this.triggerImprovement,
    required this.thresholdDistance,
    required this.recentLogs,
  });

  String get progressLabel {
    if (avgProgressScore >= 7) return 'Mükemmel İlerleme! 🌟';
    if (avgProgressScore >= 5) return 'İyi Gidiyor 👍';
    if (avgProgressScore >= 3) return 'Devam Ediyoruz 💪';
    return 'Sabırla Çalışıyoruz 🤍';
  }
}
