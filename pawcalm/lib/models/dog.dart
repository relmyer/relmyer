import 'package:cloud_firestore/cloud_firestore.dart';

enum DogSize { small, medium, large, giant }
enum DogReactivityLevel { none, mild, moderate, severe }

class Dog {
  final String id;
  final String ownerId;
  final String name;
  final String breed;
  final int ageMonths;
  final DogSize size;
  final DogReactivityLevel reactivityLevel;
  final List<String> triggers;       // e.g. ['other dogs', 'bicycles', 'loud noises']
  final List<String> fears;          // e.g. ['thunder', 'fireworks']
  final String? photoUrl;
  final String? notes;
  final DateTime createdAt;

  Dog({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.breed,
    required this.ageMonths,
    this.size = DogSize.medium,
    this.reactivityLevel = DogReactivityLevel.moderate,
    this.triggers = const [],
    this.fears = const [],
    this.photoUrl,
    this.notes,
    required this.createdAt,
  });

  String get ageString {
    if (ageMonths < 12) return '$ageMonths ay';
    final years = ageMonths ~/ 12;
    final months = ageMonths % 12;
    if (months == 0) return '$years yaş';
    return '$years yaş $months ay';
  }

  String get sizeLabel {
    switch (size) {
      case DogSize.small: return 'Küçük (< 10 kg)';
      case DogSize.medium: return 'Orta (10-25 kg)';
      case DogSize.large: return 'Büyük (25-45 kg)';
      case DogSize.giant: return 'Dev (> 45 kg)';
    }
  }

  String get reactivityLabel {
    switch (reactivityLevel) {
      case DogReactivityLevel.none: return 'Reaktif Değil';
      case DogReactivityLevel.mild: return 'Hafif Reaktif';
      case DogReactivityLevel.moderate: return 'Orta Reaktif';
      case DogReactivityLevel.severe: return 'Şiddetli Reaktif';
    }
  }

  factory Dog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Dog(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      ageMonths: data['ageMonths'] ?? 0,
      size: DogSize.values.firstWhere(
        (e) => e.name == data['size'],
        orElse: () => DogSize.medium,
      ),
      reactivityLevel: DogReactivityLevel.values.firstWhere(
        (e) => e.name == data['reactivityLevel'],
        orElse: () => DogReactivityLevel.moderate,
      ),
      triggers: List<String>.from(data['triggers'] ?? []),
      fears: List<String>.from(data['fears'] ?? []),
      photoUrl: data['photoUrl'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'name': name,
      'breed': breed,
      'ageMonths': ageMonths,
      'size': size.name,
      'reactivityLevel': reactivityLevel.name,
      'triggers': triggers,
      'fears': fears,
      'photoUrl': photoUrl,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Dog copyWith({
    String? name,
    String? breed,
    int? ageMonths,
    DogSize? size,
    DogReactivityLevel? reactivityLevel,
    List<String>? triggers,
    List<String>? fears,
    String? photoUrl,
    String? notes,
  }) {
    return Dog(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      ageMonths: ageMonths ?? this.ageMonths,
      size: size ?? this.size,
      reactivityLevel: reactivityLevel ?? this.reactivityLevel,
      triggers: triggers ?? this.triggers,
      fears: fears ?? this.fears,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
