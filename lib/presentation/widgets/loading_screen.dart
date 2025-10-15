import 'package:flutter/material.dart';

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
            Text('جاري التحميل... ${(progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}