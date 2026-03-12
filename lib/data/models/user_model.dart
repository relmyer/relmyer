import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final double weightKg;
  final double heightCm;
  final int totalSteps;
  final double totalDistanceM;
  final double totalCalories;
  final int totalWalks;
  final double totalAreaM2;
  final List<String> friendIds;
  final bool isMetric;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.weightKg = 70.0,
    this.heightCm = 170.0,
    this.totalSteps = 0,
    this.totalDistanceM = 0.0,
    this.totalCalories = 0.0,
    this.totalWalks = 0,
    this.totalAreaM2 = 0.0,
    this.friendIds = const [],
    this.isMetric = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      weightKg: (data['weightKg'] ?? 70.0).toDouble(),
      heightCm: (data['heightCm'] ?? 170.0).toDouble(),
      totalSteps: data['totalSteps'] ?? 0,
      totalDistanceM: (data['totalDistanceM'] ?? 0.0).toDouble(),
      totalCalories: (data['totalCalories'] ?? 0.0).toDouble(),
      totalWalks: data['totalWalks'] ?? 0,
      totalAreaM2: (data['totalAreaM2'] ?? 0.0).toDouble(),
      friendIds: List<String>.from(data['friendIds'] ?? []),
      isMetric: data['isMetric'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'totalSteps': totalSteps,
      'totalDistanceM': totalDistanceM,
      'totalCalories': totalCalories,
      'totalWalks': totalWalks,
      'totalAreaM2': totalAreaM2,
      'friendIds': friendIds,
      'isMetric': isMetric,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    double? weightKg,
    double? heightCm,
    int? totalSteps,
    double? totalDistanceM,
    double? totalCalories,
    int? totalWalks,
    double? totalAreaM2,
    List<String>? friendIds,
    bool? isMetric,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      totalSteps: totalSteps ?? this.totalSteps,
      totalDistanceM: totalDistanceM ?? this.totalDistanceM,
      totalCalories: totalCalories ?? this.totalCalories,
      totalWalks: totalWalks ?? this.totalWalks,
      totalAreaM2: totalAreaM2 ?? this.totalAreaM2,
      friendIds: friendIds ?? this.friendIds,
      isMetric: isMetric ?? this.isMetric,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
