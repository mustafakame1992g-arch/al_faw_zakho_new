import 'package:hive/hive.dart';

part 'news_model.g.dart';

/// 📰 NewsModel — تصميم متين ومرن للـJSON (camel/snake)
@HiveType(typeId: 1)
class NewsModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String titleAr;
  @HiveField(2)
  final String titleEn;
  @HiveField(3)
  final String contentAr;
  @HiveField(4)
  final String contentEn;

  @HiveField(5)
  final String imagePath; // ملاحظة: اسم الحقل داخليًا imagePath
  @HiveField(6)
  final DateTime publishDate;
  @HiveField(7)
  final String author;
  @HiveField(8)
  final String category;
  @HiveField(9)
  final bool isBreaking;
  @HiveField(10)
  final int viewCount;

  const NewsModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.contentAr,
    required this.contentEn,
    required this.imagePath,
    required this.publishDate,
    required this.author,
    required this.category,
    required this.isBreaking,
    required this.viewCount,
  });

  // -----------------------------
  // Parsing Helpers (آمنة ومرنة)
  // -----------------------------
  // ignore: non_constant_identifier_names
  static String _S(dynamic v) => (v ?? '').toString().trim();

  // ignore: non_constant_identifier_names
  static bool _B(dynamic v) {
    if (v is bool) return v;
    final s = _S(v).toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }

  // ignore: non_constant_identifier_names
  static int _I(dynamic v) {
    if (v is int) return v;
    final s = _S(v);
    final n = int.tryParse(s);
    return n ?? 0;
  }

  // ignore: non_constant_identifier_names
  static DateTime _D(dynamic v) {
    try {
      if (v is DateTime) return v;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      final s = _S(v);
      return s.isEmpty ? DateTime.now() : DateTime.parse(s);
    } catch (_) {
      return DateTime.now();
    }
  }

  // ---------------------------------------
  // JSON (يدعم snake_case و camelCase)
  // ---------------------------------------
  factory NewsModel.fromJson(Map<String, dynamic> j) {
    final id = _S(j['id']);
    final titleAr = _S(j['title_ar'] ?? j['titleAr'] ?? j['title']);
    final titleEn = _S(j['title_en'] ?? j['titleEn'] ?? j['title']);

    final contentAr = _S(j['content_ar'] ?? j['contentAr'] ?? j['content']);
    final contentEn = _S(j['content_en'] ?? j['contentEn'] ?? j['content']);
    final imagePath = _S(j['image_url'] ?? j['imagePath'] ?? j['image']);

    final publishDate = _D(j['publish_date'] ?? j['publishDate']);
    final author = _S(j['author']);
    final category = _S(j['category']).isEmpty ? 'عام' : _S(j['category']);
    final isBreaking = _B(j['is_breaking'] ?? j['isBreaking']);
    final viewCount = _I(j['view_count'] ?? j['viewCount']);

    return NewsModel(
      id: id,
      titleAr: titleAr,
      titleEn: titleEn,
      contentAr: contentAr,
      contentEn: contentEn,
      imagePath: imagePath,
      publishDate: publishDate,
      author: author,
      category: category,
      isBreaking: isBreaking,
      viewCount: viewCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title_ar': titleAr,
        'title_en': titleEn,
        'content_ar': contentAr,
        'content_en': contentEn,
        'image_url': imagePath, // نُخرج snake_case
        'publish_date': publishDate.toIso8601String(),
        'author': author,
        'category': category,
        'is_breaking': isBreaking,
        'view_count': viewCount,
      };

  /// عنوان العرض بحسب اللغة مع fallback ذكي
  String bestTitleForLocale(String code) {
    if (code == 'en' && titleEn.isNotEmpty) return titleEn;
    if (titleAr.isNotEmpty) return titleAr;
    return titleEn; // fallback أخير
  }

  /// محتوى العرض بحسب اللغة مع fallback
  String bestContentForLocale(String code) {
    if (code == 'en' && contentEn.isNotEmpty) return contentEn;
    if (contentAr.isNotEmpty) return contentAr;
    return contentEn;
  }

  /// Comparator جاهز: العاجل أولاً ثم الأحدث
  static int breakingThenNewest(NewsModel a, NewsModel b) {
    final br = (b.isBreaking ? 1 : 0).compareTo(a.isBreaking ? 1 : 0);
    return br != 0 ? br : b.publishDate.compareTo(a.publishDate);
  }

  /// إنشاء قائمة آمنة من JSON (يتجاهل السجلات التالفة)
  static List<NewsModel> listFromJson(List<dynamic> arr) {
    final out = <NewsModel>[];
    for (final e in arr) {
      try {
        out.add(NewsModel.fromJson(Map<String, dynamic>.from(e as Map)));
      } catch (_) {
        // تجاهل العنصر التالف
      }
    }
    return out;
  }

  // -----------------------------
  // CopyWith (متوافق للخلفية)
  // -----------------------------
  NewsModel copyWith({
    String? id,
    String? titleAr,
    String? titleEn,
    String? contentAr,
    String? contentEn,
    String? imagePath, // الاسم الصحيح المتوافق مع الحقل
    String? imageUrl, // متوافق للخلفية (سوف يُستَخدم إن لم يُمرّر imagePath)
    DateTime? publishDate,
    String? author,
    String? category,
    bool? isBreaking,
    int? viewCount,
  }) {
    final nextImagePath = imagePath ?? imageUrl ?? this.imagePath;
    return NewsModel(
      id: id ?? this.id,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      contentAr: contentAr ?? this.contentAr,
      contentEn: contentEn ?? this.contentEn,
      imagePath: nextImagePath,
      publishDate: publishDate ?? this.publishDate,
      author: author ?? this.author,
      category: category ?? this.category,
      isBreaking: isBreaking ?? this.isBreaking,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NewsModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
