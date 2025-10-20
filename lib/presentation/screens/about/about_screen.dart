import 'package:flutter/material.dart';
import '/presentation/themes/app_theme.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

     return FZScaffold(
      appBar: AppBar(
        title: const Text('حول التجمع'),
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
            const Text(
              'تجمع الفاو زاخو',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'من أجل عراق موحد، من الجنوب إلى الشمال',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // نبذة
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .3),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'تجمع الفاو زاخو هو مبادرة وطنية تهدف إلى توحيد الجهود بين أبناء المحافظات العراقية من الفاو إلى زاخو، '
                  'لتشجيع المشاركة الواعية في العملية الانتخابية ودعم الكفاءات الوطنية المستقلة.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(height: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 24),
            _infoRow('📍', 'المقر الرئيسي: البصرة – العراق'),
            _infoRow('🏢', 'التأسيس: 2024'),
            _infoRow('🎯', 'الهدف: نشر الوعي الانتخابي ودعم الكفاءات الوطنية'),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.language, size: 30),
                SizedBox(width: 16),
                Icon(Icons.email_outlined, size: 30),
                SizedBox(width: 16),
                Icon(Icons.facebook, size: 30),
                SizedBox(width: 16),
                Icon(Icons.phone, size: 30),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'جميع الحقوق محفوظة © 2025\nتجمع الفاو زاخو – الإصدار 2.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
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
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
