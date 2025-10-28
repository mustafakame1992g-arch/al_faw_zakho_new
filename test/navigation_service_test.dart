// test/navigation_service_test.dart - النسخة المصححة
import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:al_faw_zakho/core/navigation/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('goHome resets stack', (tester) async {
    final nav = NavigationService();

    await tester.pumpWidget(
      MaterialApp(
        // ✅ إضافة navigatorKey لربط الـ NavigationService
        navigatorKey: NavigationService.navigatorKey,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: {
          NavigationService.homeRoute: (_) =>
              const Scaffold(body: Text('Home')),
          '/second': (_) => const Scaffold(body: Text('Second')),
        },
        initialRoute: '/second',
      ),
    );

    await tester.pumpAndSettle();

    // ✅ التحقق من وجود الشاشة الثانية
    expect(find.text('Second'), findsOneWidget);

    // ✅ الحصول على السياق من العنصر الموجود
    final element = tester.element(find.text('Second'));
    final BuildContext ctx = element;

    // ✅ استدعاء goHome
    nav.goHome(ctx);
    await tester.pumpAndSettle();

    // ✅ التحقق من أن الشاشة الرئيسية ظهرت
    expect(find.text('Home'), findsOneWidget);
  });
}