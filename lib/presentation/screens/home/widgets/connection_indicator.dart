import 'package:al_faw_zakho/core/providers/connectivity_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 🌐 مؤشّر الاتصال بالإنترنت
class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, _) {
        final isOnline = connectivity.isOnline;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: isOnline ? Colors.green[50] : Colors.orange[50],
            border: Border.all(
              color: isOnline ? Colors.green : Colors.orange,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOnline ? Icons.wifi : Icons.signal_wifi_off,
                color: isOnline ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 6),
              Text(
                isOnline ? 'متصل بالإنترنت' : 'لا يوجد اتصال',
                style: TextStyle(
                  color: isOnline ? Colors.green[800] : Colors.orange[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
