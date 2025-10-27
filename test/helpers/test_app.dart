import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget wrapWithTestApp(Widget child, {Locale? locale}) {
  return MaterialApp(
    locale: locale ?? const Locale('ar'), // اجعلها 'ar' لتستقر النصوص العربية
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}
