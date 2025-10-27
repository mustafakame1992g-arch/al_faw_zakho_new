import 'dart:developer' as dev;

class Logger {
  Logger(this.tag);
  final String tag;
  void d(String msg) => dev.log(msg, name: tag);
  void e(String msg, [Object? error, StackTrace? st]) =>
      dev.log(msg, name: tag, error: error, stackTrace: st);
}
