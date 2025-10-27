import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, this.progress = 0.0});
  final double progress;

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
              '${AppLocalizations.of(context).translate('loading')}... ${(progress * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
      ),
    );
  }
}
