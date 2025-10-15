import 'package:flutter/material.dart';

/// ⚙️ إعدادات النصوص الخاصة بالخطأ (تُستخدم من DefaultDataService)
class ErrorConfig {
  final String title;
  final String ctaLabel;
  final bool showRetry;

  ErrorConfig({
    required this.title,
    required this.ctaLabel,
    required this.showRetry,
  });
}

/// 🧱 شاشة عرض الأخطاء العامة في التطبيق
class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final String ctaLabel;
  final VoidCallback onRetry;
  final bool showRetry;

  const ErrorScreen({
    super.key,
    required this.title,
    required this.message,
    required this.ctaLabel,
    required this.onRetry,
    this.showRetry = true,
  });

  @override
  Widget build(BuildContext context) {
     final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🎨 ألوان الهوية الرسمية لتجمع الفاو زاخو
    const Color fawRed = Color(0xFFD32F2F);
    const Color fawGold = Color(0xFFFFD54F);
    const Color fawBlack = Color(0xFF1C1C1C);

    final Color backgroundColor = isDark ? fawBlack : Colors.grey[50]!;
    final Color titleColor = isDark ? fawGold : fawRed;
    final Color textColor = isDark ? Colors.white70 : Colors.black87;
    final Color buttonColor = isDark ? fawGold : fawRed;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? fawBlack : fawRed,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'حدث خطأ',
          style: TextStyle(
            color: isDark ? fawGold : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🖼️ شعار تجمع الفاو زاخو
                AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(seconds: 1),
                  child: Image.asset(
                    'assets/images/faw_zakho_logo.png', // تأكد من وجود الصورة بهذا المسار
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 20),
                Icon(
                  Icons.error_outline,
                  color: isDark ? fawGold : fawRed,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),


              const SizedBox(height: 12),
              Text(
                message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (showRetry)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: Icon(
                      Icons.refresh,
                      color: isDark ? fawBlack : Colors.white,
                    ),
                    label: Text(
                      ctaLabel,
                      style: TextStyle(
                        color: isDark ? fawBlack : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

