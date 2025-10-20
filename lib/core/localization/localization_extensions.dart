import 'package:flutter/widgets.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';

extension SafeTr on BuildContext {
  String trSafe(String key, {String? fallback}) {
    try {
      final t = AppLocalizations.of(this);
      if (t == null) return fallback ?? key;
      return t.translate(key);
    } catch (_) {
      return fallback ?? key;
    }
  }
}
