// lib/domain/entities/candidate.dart
class Candidate {
  final String id;
  final String name;
  final String nameEn;
  final String position;
  final String bio;
  final String bioEn;
  final String imageUrl;
  final String phoneNumber;
  final String province;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Candidate({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.position,
    required this.bio,
    required this.bioEn,
    required this.imageUrl,
    required this.phoneNumber,
    required this.province,
    required this.createdAt,
    required this.updatedAt,
  });
}
