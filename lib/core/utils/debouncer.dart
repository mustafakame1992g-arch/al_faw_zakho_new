// lib/core/utils/debouncer.dart
import 'dart:async' show Timer;
import 'dart:ui' show VoidCallback;

class Debouncer {
  Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
