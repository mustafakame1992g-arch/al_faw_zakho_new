import 'package:flutter/material.dart';
import 'package:al_faw_zakho/presentation/themes/app_theme.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';

// ⚠️ ضروري لاستعمال context.tr / context.trf
import 'package:al_faw_zakho/core/localization/localization_extensions.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _appVersion = '2.0.0';

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return FZScaffold(
      appBar: AppBar(
        title: Text(context.tr('about_title')),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.headerGradient(brightness),
          ),
        ),
      ),
      persistentBottom: FZTab.about,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 100, height: 100),
            const SizedBox(height: 16),

            // الاسم
            Text(
              context.tr('about_name'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            // الشعار
            Text(
              context.tr('about_motto'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // نبذة تعريفية
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              // إن كانت لديك Flutter قديمة ولا تدعم withValues استعمل withOpacity(0.08)
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: .08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.tr('about_intro'),
                  textAlign: TextAlign.justify,
                  style: const TextStyle(height: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // معلومات مختصرة (كلها مفاتيح ترجمة)
            _infoRow('📍', context.tr('about_hq')),
            _infoRow('🏢', context.tr('about_founded')),
            _infoRow('🎯', context.tr('about_goal')),

            const SizedBox(height: 24),

            // أيقونات قنوات التواصل (مع Semantics/Tooltip لسهولة الوصول)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _IconRound(icon: Icons.language, tooltip: 'Website'),
                SizedBox(width: 16),
                _IconRound(icon: Icons.email_outlined, tooltip: 'Email'),
                SizedBox(width: 16),
                _IconRound(icon: Icons.facebook, tooltip: 'Facebook'),
                SizedBox(width: 16),
                _IconRound(icon: Icons.phone, tooltip: 'Phone'),
              ],
            ),

            const SizedBox(height: 24),

            // حقوق النشر بديناميكية السنة/الإصدار عبر trf
            Text(
              context.trf('rights_reserved', {
                'year': DateTime.now().year.toString(),
                'version': _appVersion,
              }),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconRound extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  const _IconRound({required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.08),
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}
