// lib/data/static/iraqi_provinces.dart

/// 🗺️ قائمة المحافظات العراقية الـ 19
class IraqiProvinces {
  // القائمة الكاملة للمحافظات العراقية
  static const List<String> allProvinces = [
    'بغداد',
    'البصرة',
    'نينوى',
    'أربيل',
    'السليمانية',
    'دهوك',
    'كركوك',
    'ديالى',
    'الأنبار',
    'صلاح الدين',
    'بابل',
    'كربلاء',
    'النجف',
    'واسط',
    'ميسان',
    'ذي قار',
    'القادسية',
    'المثنى',
    'حلبجة',
  ];
    // أسماء العرض بالإنجليزية مقابل الاسم العربي (نحتفظ بالعربي كمفتاح داخلي)
  static const Map<String, String> arToEn = {
    'بغداد': 'Baghdad',
    'البصرة': 'Basra',
    'نينوى': 'Nineveh',
    'أربيل': 'Erbil',
    'السليمانية': 'Sulaymaniyah',
    'دهوك': 'Duhok',
    'كركوك': 'Kirkuk',
    'ديالى': 'Diyala',
    'الأنبار': 'Anbar',
    'صلاح الدين': 'Salah al-Din',
    'بابل': 'Babil',
    'كربلاء': 'Karbala',
    'النجف': 'Najaf',
    'واسط': 'Wasit',
    'ميسان': 'Maysan',
    'ذي قار': 'Dhi Qar',
    'القادسية': 'Al-Qadisiyah',
    'المثنى': 'Muthanna',
    'حلبجة': 'Halabja',
  };

  /// ترجمة اسم المحافظة للعرض فقط حسب كود اللغة ('ar' أو 'en')
  static String displayName(String arName, String langCode) {
    if (langCode == 'en') {
      return arToEn[arName] ?? arName;
    }
    return arName;
  }


  /// التحقق من صحة المحافظة
  static bool isValidProvince(String province) {
    return allProvinces.contains(province);
  }

  /// الحصول على عدد المحافظات
  static int get totalCount => allProvinces.length;

  /// الحصول على محافظة بالرقم التسلسلي
  static String getProvinceByIndex(int index) {
    if (index < 0 || index >= allProvinces.length) {
      throw RangeError('Index $index is out of bounds for provinces list');
    }
    return allProvinces[index];
  }

  /// البحث عن محافظة
  static String? findProvince(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    for (final province in allProvinces) {
      if (province.toLowerCase().contains(normalizedQuery)) {
        return province;
      }
    }
    return null;
  }

  /// الحصول على أسماء المحافظات للغة محددة
  static List<String> getProvincesForLanguage(String languageCode) {
    // في هذه الحالة، القائمة واحدة للغتين
    // يمكن توسيعها في المستقبل إذا احتجنا ترجمة الأسماء
    return allProvinces;
  }

  /// التحقق من اكتمال البيانات
  static bool get isComplete => allProvinces.length == 19;

  /// الحصول على خريطة المحافظات مع عدد المرشحين (للاستخدام المستقبلي)
  static Map<String, int> getProvinceCandidateCounts(List<dynamic> candidates) {
    final Map<String, int> counts = {};
    for (final province in allProvinces) {
      counts[province] = 0;
    }
    
    for (final candidate in candidates) {
      if (candidate.province != null && isValidProvince(candidate.province)) {
        counts[candidate.province] = (counts[candidate.province] ?? 0) + 1;
      }
    }
    
    return counts;
  }
}