// lib/presentation/screens/home/widgets/welcome_banner.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/core/providers/language_provider.dart';

class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.flag, size: 48, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              _getWelcomeMessage(languageProvider.locale.languageCode),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              _getSubtitleMessage(languageProvider.locale.languageCode),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getWelcomeMessage(String languageCode) {
    switch (languageCode) {
      case 'ar': return 'مرحباً بكم في تطبيق تجمع الفاو زاخو';
      default: return 'Welcome to Faw Zaho Gathering App';
    }
  }

  String _getSubtitleMessage(String languageCode) {
    switch (languageCode) {
      case 'ar': return 'منصة سياسية شاملة للتعريف بالبرنامج الانتخابي والمرشحين';
      default: return 'Comprehensive political platform for introducing the electoral program and candidates';
    }
  }
}
