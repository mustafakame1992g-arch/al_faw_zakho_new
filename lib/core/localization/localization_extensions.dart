import 'package:flutter/widgets.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';

/// أدوات ترجمة مريحة وآمنة للاستعمال من أي Widget عبر BuildContext.
/// - context.tr('key')  => ترجمة المفتاح أو يرجع المفتاح نفسه عند الفشل.
/// - context.trf('key', {'name':'Mustafa'}) => ترجمة مع استبدال {placeholders}.
/// - context.langCode   => 'ar' أو 'en'.
/// - context.isArabic   => true إذا اللغة الحالية عربية.
/// - context.pick(ar: '...', en: '...') => يختار القيمة بحسب اللغة.
extension L10nX on BuildContext {
  /// ترجمة آمنة مع خيار fallback (للخلفية/التوافق القديم).
  String trSafe(String key, {String? fallback}) {
    try {
      final t = AppLocalizations.of(this);
      return t.translate(key);
    } catch (_) {
      return fallback ?? key;
    }
  }

  /// ترجمة أساسية (تستعمل trSafe داخلياً).
  String tr(String key) => trSafe(key);

  /// ترجمة مع استبدال {placeholders}. القيم غير الموجودة تُترك كما هي.
  String trf(String key, [Map<String, String>? vars]) {
    var text = tr(key);
    if (vars == null || vars.isEmpty) return text;

    return text.replaceAllMapped(
      RegExp(r'\{(\w+)\}'), // يلتقط {var}
      (m) {
        final k = m.group(1)!;
        return vars[k] ?? m.group(0)!; // إن لم توجد، اتركها كما هي
      },
    );
  }

  /// كود اللغة الحالية.
  String get langCode => Localizations.localeOf(this).languageCode;

  /// هل اللغة الحالية عربية؟
  bool get isArabic => langCode == 'ar';

  /// اختيار قيمة بناء على اللغة الحالية.
  T pick<T>({required T ar, required T en}) => isArabic ? ar : en;

  /// اتجاه النص الحالي (قد يفيدك أحياناً).
  TextDirection get textDir => Directionality.of(this);
}
