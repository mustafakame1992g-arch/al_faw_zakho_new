// lib/presentation/screens/candidates/candidate_details_screen.dart
import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:al_faw_zakho/core/providers/language_provider.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/data/models/candidate_model.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CandidateDetailsScreen extends StatelessWidget {
  const CandidateDetailsScreen({
    super.key,
    required this.candidate,
  });
  final CandidateModel candidate;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.languageCode;

    // تتبع التحليلات
    AnalyticsService.trackEvent(
      'candidate_details_opened',
      parameters: {
        'candidate_id': candidate.id,
        'candidate_name': candidate.nameAr,
        'province': candidate.province,
      },
    );

    return FZScaffold(
      appBar: AppBar(
        title: Text(context.tr('candidate_details')),
        centerTitle: true,
        elevation: 2,
      ),
      persistentBottom: FZTab.home,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCandidatePhoto(context),
            const SizedBox(height: 24),
            _buildCandidateName(currentLanguage),
            const SizedBox(height: 16),
            _buildCandidateNickname(currentLanguage),
            const SizedBox(height: 24),
            _buildCandidateBio(currentLanguage),
            const SizedBox(height: 24),
            _buildCandidatePhone(context),
          ],
        ),
      ),
    );
  }

  // 🖼️ صورة المرشح
  Widget _buildCandidatePhoto(BuildContext context) {
    final path = candidate.imagePath.trim();
    final borderRadius = BorderRadius.circular(12);

    Widget image;
    if (path.isNotEmpty && path.startsWith('http')) {
      image = Image.network(
        path,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (path.isNotEmpty) {
      image = Image.asset(
        path,
        height: 200,
        width: double.infinity,
        fit: BoxFit.contain,
      );
    } else {
      image = Image.asset(
        'assets/images/logo.png',
        height: 100,
        width: 100,
        fit: BoxFit.contain,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(
          //border: Border.all(color: Colors.blue.shade200, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],

          borderRadius: borderRadius,
        ),
        child: image,
      ),
    );
  }

  // 📛 الاسم الثلاثي
  Widget _buildCandidateName(String languageCode) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Text(
            languageCode == 'en' ? candidate.nameEn : candidate.nameAr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'الاسم الثلاثي',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 🏷️ اللقب
  Widget _buildCandidateNickname(String languageCode) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Text(
            candidate.getNickname(languageCode),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'معلومات يوم الانتخاب',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 📜 السيرة الذاتية
  Widget _buildCandidateBio(String languageCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              'السيرة الذاتية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            languageCode == 'en' ? candidate.bioEn : candidate.bioAr,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  // 📞 رقم الهاتف (عرض فقط + نسخ عند النقر)
  Widget _buildCandidatePhone(BuildContext context) {
    final phone = candidate.phoneNumber.trim();
    if (phone.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.phone,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('mobile_number'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _copyPhoneNumber(context, phone),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_android, color: Colors.red.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    phone,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
                Icon(
                  Icons.content_copy,
                  color: Colors.red.shade700,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _copyPhoneNumber(BuildContext context, String phone) async {
    // نأخذ ما نحتاجه من الـ context قبل أي await
    final messenger = ScaffoldMessenger.of(context);
    final tr = AppLocalizations.of(context);

    // تنظيف وتحقق مبكر للمدخل
    final text = phone.trim();
    if (text.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ ${tr.translate('copy_failed')}'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // العملية غير المتزامنة
      await Clipboard.setData(ClipboardData(text: text));

      // إظهار الرسالة باستخدام المرجع الملتقط مسبقًا (لا نستخدم context بعد await)
      messenger.showSnackBar(
        SnackBar(
          content: Text('${tr.translate('phone_copied')} $text'),
          duration: const Duration(seconds: 2),
        ),
      );

      // تتبع الحدث (احتفظت على نفس الباراميترات لديك)
      AnalyticsService.trackEvent(
        'candidate_phone_copied',
        parameters: {
          'candidate_id': candidate
              .id, // يفترض أن الدالة داخل نفس الكلاس الذي يملك candidate
          'phone_number': text,
        },
      );
    } catch (e) {
      // في حال الفشل
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ ${tr.translate('copy_failed')}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
