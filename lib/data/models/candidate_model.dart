import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'candidate_model.g.dart';

@HiveType(typeId: 3)
class CandidateModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String nameAr;
  @HiveField(2)
  final String nameEn;
  @HiveField(3)
  final String nicknameAr;
  @HiveField(4)
  final String nicknameEn;
  @HiveField(5)
  final String positionAr;
  @HiveField(6)
  final String positionEn;
  @HiveField(7)
  final String bioAr;
  @HiveField(8)
  final String bioEn;
  @HiveField(9)
  final String imagePath;
  @HiveField(10)
  final String phoneNumber;
  @HiveField(11)
  final String province;
  @HiveField(12)
  final DateTime createdAt;
  @HiveField(13)
  final DateTime updatedAt;
  @HiveField(14)
  final String? listName;
  @HiveField(15)
  final String? listLogo;

  const CandidateModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nicknameAr,
    required this.nicknameEn,
    required this.positionAr,
    required this.positionEn,
    required this.bioAr,
    required this.bioEn,
    required this.imagePath,
    required this.phoneNumber,
    required this.province,
    required this.createdAt,
    required this.updatedAt,
    this.listName,
    this.listLogo,
  });

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'nicknameAr': nicknameAr,
        'nicknameEn': nicknameEn,
        'positionAr': positionAr,
        'positionEn': positionEn,
        'bioAr': bioAr,
        'bioEn': bioEn,
        'imagePath': imagePath,
        'phoneNumber': phoneNumber,
        'province': province,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'listName': listName,
        'listLogo': listLogo,
      };

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      try {
        return value == null
            ? DateTime.now()
            : DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    String parseString(dynamic value) => (value ?? '').toString().trim();

    return CandidateModel(
      id: parseString(json['id']),
      nameAr: parseString(json['nameAr']),
      nameEn: parseString(json['nameEn']),
      nicknameAr: parseString(json['nicknameAr']),
      nicknameEn: parseString(json['nicknameEn']),
      positionAr: parseString(json['positionAr']),
      positionEn: parseString(json['positionEn']),
      bioAr: parseString(json['bioAr']),
      bioEn: parseString(json['bioEn']),
      imagePath: parseString(json['imagePath']),
      phoneNumber: parseString(json['phoneNumber']),
      province: parseString(json['province']),
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
      listName: json['listName'] == null ? null : parseString(json['listName']),
      listLogo: json['listLogo'] == null ? null : parseString(json['listLogo']),
    );
  }

  // Validation
  void validate() {
    if (id.isEmpty) throw FormatException('معرف المرشح مطلوب');
    if (nameAr.isEmpty && nameEn.isEmpty) throw FormatException('الاسم مطلوب');
    if (province.isEmpty) throw FormatException('المحافظة مطلوبة');

    // Phone validation
    if (phoneNumber.isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[\d\s\-]{7,15}$');
      if (!phoneRegex.hasMatch(phoneNumber)) {
        throw FormatException('رقم الهاتف غير صالح');
      }
    }
  }

  // Helper methods
  String getName(String languageCode) => languageCode == 'en' ? nameEn : nameAr;
  String getNickname(String languageCode) =>
      languageCode == 'en' ? nicknameEn : nicknameAr;
  String getPosition(String languageCode) =>
      languageCode == 'en' ? positionEn : positionAr;
  String getBio(String languageCode) => languageCode == 'en' ? bioEn : bioAr;

  bool get hasImage => imagePath.isNotEmpty;
  bool get hasBasicInfo => nameAr.isNotEmpty || nameEn.isNotEmpty;

  CandidateModel copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? nicknameAr,
    String? nicknameEn,
    String? positionAr,
    String? positionEn,
    String? bioAr,
    String? bioEn,
    String? imagePath,
    String? phoneNumber,
    String? province,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? listName,
    String? listLogo,
  }) {
    return CandidateModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      nicknameAr: nicknameAr ?? this.nicknameAr,
      nicknameEn: nicknameEn ?? this.nicknameEn,
      positionAr: positionAr ?? this.positionAr,
      positionEn: positionEn ?? this.positionEn,
      bioAr: bioAr ?? this.bioAr,
      bioEn: bioEn ?? this.bioEn,
      imagePath: imagePath ?? this.imagePath,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      province: province ?? this.province,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      listName: listName ?? this.listName,
      listLogo: listLogo ?? this.listLogo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        nicknameAr,
        nicknameEn,
        positionAr,
        positionEn,
        bioAr,
        bioEn,
        imagePath,
        phoneNumber,
        province,
        createdAt,
        updatedAt,
        listName,
        listLogo,
      ];

  @override
  String toString() =>
      'CandidateModel($id, $nameAr/$nameEn, $province, list=$listName)';
}
