import 'package:hive/hive.dart';

part 'faq_model.g.dart';

/// ❓ FAQModel (ar/en only) - Enhanced Version
@HiveType(typeId: 4)
class FaqModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String questionAr;
  @HiveField(2)
  final String questionEn;
  @HiveField(3)
  final String answerAr;
  @HiveField(4)
  final String answerEn;
  @HiveField(5)
  final String category;
  @HiveField(6)
  final int importance;
  @HiveField(7)
  final List<String> tags;
  @HiveField(8)
  final DateTime createdAt;
  @HiveField(9)
  final int viewCount;

  const FaqModel({
    required this.id,
    required this.questionAr,
    required this.questionEn,
    required this.answerAr,
    required this.answerEn,
    required this.category,
    required this.importance,
    required this.tags,
    required this.createdAt,
    required this.viewCount,
  });

  // 🚀 Enhanced JSON Parser with maximum flexibility
  factory FaqModel.fromJson(Map<String, dynamic> json) {
    // Helper function for safe parsing with multiple key support
    T getValue<T>(
        List<String> keys, T defaultValue, T Function(dynamic) parser) {
      try {
        for (final key in keys) {
          if (json.containsKey(key)) {
            final value = json[key];
            if (value != null) {
              return parser(value);
            }
          }
        }
        return defaultValue;
      } catch (e) {
        return defaultValue;
      }
    }

    // String parser with fallback
    String parseString(List<String> keys, [String defaultValue = '']) =>
        getValue<String>(keys, defaultValue, (v) => v.toString());

    // Int parser with fallback
    int parseInt(List<String> keys, [int defaultValue = 0]) =>
        getValue<int>(keys, defaultValue, (v) {
          if (v is int) return v;
          if (v is double) return v.toInt();
          if (v is String) return int.tryParse(v) ?? defaultValue;
          return defaultValue;
        });

    // DateTime parser with multiple format support
    DateTime parseDateTime(List<String> keys) =>
        getValue<DateTime>(keys, DateTime.now(), (v) {
          if (v is DateTime) return v;
          if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
          if (v is String) {
            // Try multiple date formats
            final dateTime = DateTime.tryParse(v);
            if (dateTime != null) return dateTime;

            // Try milliseconds since epoch string
            final milliseconds = int.tryParse(v);
            if (milliseconds != null) {
              return DateTime.fromMillisecondsSinceEpoch(milliseconds);
            }
          }
          return DateTime.now();
        });

    // List<String> parser
    List<String> parseStringList(List<String> keys) =>
        getValue<List<String>>(keys, const <String>[], (v) {
          if (v is List) {
            return v.whereType<String>().toList();
          }
          if (v is String) {
            // Handle comma-separated strings
            return v
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
          return const <String>[];
        });

    return FaqModel(
      id: parseString(['id', 'ID', '_id'], ''),

      // Support for both camelCase and snake_case with multiple variations
      questionAr: parseString(
          ['question_ar', 'questionAr', 'question_ar', 'question_arabic']),
      questionEn: parseString(
          ['question_en', 'questionEn', 'question_en', 'question_english']),
      answerAr:
          parseString(['answer_ar', 'answerAr', 'answer_ar', 'answer_arabic']),
      answerEn:
          parseString(['answer_en', 'answerEn', 'answer_en', 'answer_english']),

      category: parseString(['category', 'cat', 'type'], 'عام'),
      importance: parseInt(['importance', 'priority', 'weight'], 1).clamp(1, 5),

      tags: parseStringList(['tags', 'tag', 'keywords']),

      createdAt:
          parseDateTime(['created_at', 'createdAt', 'created', 'timestamp']),
      viewCount: parseInt(['view_count', 'viewCount', 'views', 'view_count']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question_ar': questionAr,
        'question_en': questionEn,
        'answer_ar': answerAr,
        'answer_en': answerEn,
        'category': category,
        'importance': importance,
        'tags': tags,
        'created_at': createdAt.toIso8601String(),
        'view_count': viewCount,
      };

  // 🌍 Smart localization helpers
  String getQuestion(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'en':
        return questionEn.isNotEmpty ? questionEn : questionAr;
      case 'ar':
        return questionAr.isNotEmpty ? questionAr : questionEn;
      default:
        return questionEn.isNotEmpty ? questionEn : questionAr;
    }
  }

  String getAnswer(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'en':
        return answerEn.isNotEmpty ? answerEn : answerAr;
      case 'ar':
        return answerAr.isNotEmpty ? answerAr : answerEn;
      default:
        return answerEn.isNotEmpty ? answerEn : answerAr;
    }
  }

  // 📊 Smart getters
  bool get hasArabicContent => questionAr.isNotEmpty || answerAr.isNotEmpty;
  bool get hasEnglishContent => questionEn.isNotEmpty || answerEn.isNotEmpty;
  bool get isImportant => importance >= 4;
  int get daysSinceCreation => DateTime.now().difference(createdAt).inDays;

  // 🎯 Enhanced copyWith
  FaqModel copyWith({
    String? id,
    String? questionAr,
    String? questionEn,
    String? answerAr,
    String? answerEn,
    String? category,
    int? importance,
    List<String>? tags,
    DateTime? createdAt,
    int? viewCount,
  }) {
    return FaqModel(
      id: id ?? this.id,
      questionAr: questionAr ?? this.questionAr,
      questionEn: questionEn ?? this.questionEn,
      answerAr: answerAr ?? this.answerAr,
      answerEn: answerEn ?? this.answerEn,
      category: category ?? this.category,
      importance: importance ?? this.importance,
      tags: tags ?? List<String>.from(this.tags),
      createdAt: createdAt ?? this.createdAt,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  // 📦 Conversion helpers
  Map<String, dynamic> toMap() => toJson();

  factory FaqModel.fromMap(Map<String, dynamic> map) => FaqModel.fromJson(map);

  // 🔍 Comparison operators
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FaqModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          questionAr == other.questionAr &&
          questionEn == other.questionEn &&
          answerAr == other.answerAr &&
          answerEn == other.answerEn &&
          category == other.category &&
          importance == other.importance &&
          tags.length == other.tags.length &&
          tags.every((tag) => other.tags.contains(tag)) &&
          createdAt.millisecondsSinceEpoch ~/ 1000 ==
              other.createdAt.millisecondsSinceEpoch ~/ 1000 &&
          viewCount == other.viewCount);

  @override
  int get hashCode =>
      id.hashCode ^
      questionAr.hashCode ^
      questionEn.hashCode ^
      answerAr.hashCode ^
      answerEn.hashCode ^
      category.hashCode ^
      importance.hashCode ^
      tags.hashCode ^
      createdAt.hashCode ^
      viewCount.hashCode;

  // 📝 Enhanced toString
  @override
  String toString() {
    return 'FaqModel('
        'id: $id, '
        'questionAr: ${questionAr.length > 20 ? '${questionAr.substring(0, 20)}...' : questionAr}, '
        'questionEn: ${questionEn.length > 20 ? '${questionEn.substring(0, 20)}...' : questionEn}, '
        'category: $category, '
        'importance: $importance, '
        'tags: ${tags.take(3).toList()}, '
        'createdAt: $createdAt, '
        'viewCount: $viewCount'
        ')';
  }
}
