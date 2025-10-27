import 'package:flutter/material.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';

class LoadingScreen extends StatelessWidget {
  final double progress;

  const LoadingScreen({super.key, this.progress = 0.0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: progress > 0 ? progress : null),
            const SizedBox(height: 20),
            Text(
                '${AppLocalizations.of(context).translate('loading')}... ${(progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}
