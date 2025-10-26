import 'package:flutter/material.dart';
import 'package:al_faw_zakho/presentation/themes/app_theme.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';

/// 🗳️ شبكة أقسام الشاشة الرئيسية
///
/// تحتوي على أقسام ثابتة (مرشحونا، المكاتب، البرنامج الانتخابي، إلخ)
/// يمكن تطويرها لاحقاً لتصبح ديناميكية تُغذّى من ملف JSON أو من API.
///
/// 💡 هل ترغب أن أضيف في الخطوة القادمة تغذية هذه الشاشة من ملف JSON محلي (vision.json)
/// بحيث يمكنك تعديل النصوص والمحتوى مستقبلاً بدون المساس بالكود؟
/// بهذا تتحول إلى نظام إدارة محتوى مصغّر داخل التطبيق.
class HomeGrid extends StatelessWidget {
  final Function(String) onTap;

  const HomeGrid({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final items = [
{'id': 'candidates', 'title': AppLocalizations.of(context).translate('candidates'), 'icon': Icons.how_to_vote},
{'id': 'offices', 'title': AppLocalizations.of(context).translate('offices'), 'icon': Icons.account_balance},
{'id': 'faq', 'title': AppLocalizations.of(context).translate('faq'), 'icon': Icons.help_outline},
{'id': 'program', 'title': AppLocalizations.of(context).translate('program'), 'icon': Icons.auto_stories},
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        return InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => onTap(item['id'].toString()), // ✅ إصلاح الاسم والنوع
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppTheme.tileGradient(brightness),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1), // ✅ بديل معتمد لـ withOpacity
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'] as IconData, size: 46),
                const SizedBox(height: 12),
                Text(
                  item['title'].toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
