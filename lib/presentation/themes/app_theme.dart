// lib/presentation/themes/app_theme.dart
import 'package:flutter/material.dart';

/// 🎨 ثيم متكامل ومحسّن لتطبيق تجمع الفاو زاخو
/// دمج المزايا من الكودين مع تصحيح الأخطاء وتحسين الأداء
class AppTheme {
  // 🇮🇶 ألوان العلم العراقي - بلمسة عصرية
  static const Color red = Color(0xFFB22222); // اللون الأحمر الأساسي
  static const Color green = Color(0xFF2E7D32); // اللون الأخضر الثانوي
  static const Color black = Color(0xFF121212); // الأسود للوضع الليلي
  static const Color white = Color(0xFFFAFAFA); // الأبيض للوضع النهاري

  // 🎨 درجات الرمادي المحسنة
  static const Color grey900 = Color(0xFF1E1E1E); // الخلفية الداكنة
  static const Color grey800 = Color(0xFF232323); // السطوح الداكنة
  static const Color grey700 = Color(0xFF333333); // العناصر الداكنة
  static const Color grey200 = Color(0xFFE6E6E6); // الخلفية الفاتحة
  static const Color grey100 = Color(0xFFF3F3F3); // السطوح الفاتحة
  static const Color greyLight = Color(0xFFECECEC); // الخلفية الثانوية الفاتحة

  // ✨ الخطوط
  static const String fontFamily = 'Tajawal';

  // ⏱️ مدة التحويل بين الثيمات
  static const Duration themeAnimationDuration = Duration(milliseconds: 300);

  // ==============================================================
  // ☀️ الثيم النهاري - محسّن ومكتمل
  // ==============================================================
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: red,
      onPrimary: black,
      primaryContainer: Color(0xFFFFDAD6),
      secondary: green,
      onSecondary: white,
      secondaryContainer: Color(0xFFC8E6C9),
      error: Color(0xFFBA1A1A),
      onError: white,
      errorContainer: Color(0xFFFFDAD6),
      surface: white,
      onSurface: black,
      surfaceContainerHighest: greyLight,
      onSurfaceVariant: Color(0xFF534341),
      outline: Color(0xFF857370),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      fontFamily: fontFamily,

      // 🎯 الخلفية الرئيسية
      scaffoldBackgroundColor: white,

      // 🔝 شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        iconTheme: IconThemeData(color: black, size: 24),
      ),

      // 🃏 بطاقات
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // ⌨️ حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: greyLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: red, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFFBA1A1A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 2),
        ),
        hintStyle: TextStyle(color: Colors.black54),
        labelStyle: TextStyle(color: Colors.black87),
        floatingLabelStyle: TextStyle(color: red),
      ),

      // 📝 النصوص
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 28,
          color: black,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: black,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: black,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: black,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: Colors.black87,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: black,
        ),
      ),

      // 🎨 الأيقونات
      iconTheme: IconThemeData(
        size: 24,
        color: Colors.black87,
      ),

      // 🔘 الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: red,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: red,
          side: BorderSide(color: red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // 📱 تأثيرات اللمس
      splashColor: red.withValues(alpha: .1),
      highlightColor: red.withValues(alpha: .05),
    );
  }

  // ==============================================================
  // 🌙 الثيم الليلي - محسّن ومكتمل
  // ==============================================================
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: green,
      onPrimary: white,
      primaryContainer: Color(0xFF1B5E20),
      secondary: red,
      onSecondary: white,
      secondaryContainer: Color(0xFF8B1A1A),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      surface: grey900,
      onSurface: white,
      surfaceContainerHighest: grey800,
      onSurfaceVariant: Color(0xFFD7C3C0),
      outline: Color(0xFFA08C89),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: fontFamily,

      // 🎯 الخلفية الرئيسية
      scaffoldBackgroundColor: black,

      // 🔝 شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        iconTheme: IconThemeData(color: white, size: 24),
      ),

      // 🃏 بطاقات

      cardTheme: CardThemeData(
        color: grey900,
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // ⌨️ حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: green, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFFFFB4AB)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFFFFB4AB), width: 2),
        ),
        hintStyle: TextStyle(color: Colors.white70),
        labelStyle: TextStyle(color: Colors.white70),
        floatingLabelStyle: TextStyle(color: green),
      ),

      // 📝 النصوص
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 28,
          color: white,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: white,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: white,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: white,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: Colors.white70,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: white,
        ),
      ),

      // 🎨 الأيقونات
      iconTheme: IconThemeData(
        size: 24,
        color: Colors.white70,
      ),

      // 🔘 الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: green,
          side: BorderSide(color: green),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // 📱 تأثيرات اللمس
      splashColor: green.withValues(alpha: .1),
      highlightColor: green.withValues(alpha: .05),
    );
  }

  // ==============================================================
  // 🌈 التدرجات الجمالية المحسنة
  // ==============================================================

  /// تدرج اللون للرؤوس والأقسام الرئيسية
  static LinearGradient headerGradient(Brightness brightness) => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: brightness == Brightness.dark
            ? [green, grey900] // أخضر إلى رمادي داكن
            : [red, greyLight], // أحمر إلى رمادي فاتح
      );

  /// تدرج اللون للبطاقات والعناصر
  static LinearGradient tileGradient(Brightness brightness) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: brightness == Brightness.dark
            ? [grey800, grey700] // رمادي داكن إلى أغمق
            : [white, grey100], // أبيض إلى رمادي فاتح
      );

  /// تدرج اللون للأزرار
  static LinearGradient buttonGradient(Brightness brightness) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: brightness == Brightness.dark
            ? [green, Color(0xFF1B5E20)] // أخضر بدرجتين
            : [red, Color(0xFF8B1A1A)], // أحمر بدرجتين
      );

  // ==============================================================
  // 🎯 أدوات مساعدة
  // ==============================================================

  /// الحصول على الثيم المناسب بناءً على الوضع
  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }

  /// الحصول على التدرج المناسب للرأس
  static LinearGradient getHeaderGradient(bool isDarkMode) {
    return headerGradient(isDarkMode ? Brightness.dark : Brightness.light);
  }

  /// الحصول على التدرج المناسب للبطاقات
  static LinearGradient getTileGradient(bool isDarkMode) {
    return tileGradient(isDarkMode ? Brightness.dark : Brightness.light);
  }

  // إضافة تدرجات متقدمة وتأثيرات ضوئية
  static LinearGradient get premiumGradient => LinearGradient(
        colors: [Colors.red.shade700, Colors.green.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

// إضافة ظلال متقدمة
  static List<BoxShadow> get premiumShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: .25),
          blurRadius: 20,
          offset: Offset(0, 10),
        ),
      ];
}
