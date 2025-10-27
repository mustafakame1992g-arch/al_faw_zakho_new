import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context).translate('news'))),
      body: const Center(
        child: Text('صفحة الأخبار قيد التطوير'),
      ),
    );
  }
}
